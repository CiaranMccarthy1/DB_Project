-- settles one in-progress battle exactly once; row lock stops double counting
USE java_knight_realms;

DELIMITER //

CREATE PROCEDURE sp_settle_battle(
    IN p_battle_id INT UNSIGNED,
    IN p_outcome VARCHAR(10)
)
BEGIN
    DECLARE v_character_id INT UNSIGNED;
    DECLARE v_xp INT UNSIGNED;
    DECLARE v_drop TINYINT UNSIGNED;
    DECLARE v_boss BOOLEAN;

    SELECT b.character_id, e.xp_reward, e.drop_item_id, e.is_boss
      INTO v_character_id, v_xp, v_drop, v_boss
      FROM battles b
      JOIN enemies e ON e.enemy_id = b.enemy_id
     WHERE b.battle_id = p_battle_id
       AND b.finished_at IS NULL
     FOR UPDATE;

    IF v_character_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'battle not found or already settled';
    END IF;

    UPDATE battles
       SET finished_at = NOW(),
           outcome = p_outcome,
           xp_gained = IF(p_outcome = 'win', v_xp, 0)
     WHERE battle_id = p_battle_id;

    IF p_outcome = 'win' THEN
        UPDATE characters SET xp = xp + v_xp WHERE character_id = v_character_id;
        UPDATE character_stats
           SET battles_won = battles_won + 1,
               enemies_killed = enemies_killed + 1,
               boss_kills = boss_kills + v_boss
         WHERE character_id = v_character_id;
        IF v_drop IS NOT NULL THEN
            INSERT INTO character_inventory (character_id, item_id, quantity)
            VALUES (v_character_id, v_drop, 1)
            ON DUPLICATE KEY UPDATE
                quantity = LEAST(quantity + 1,
                    (SELECT max_stack FROM items WHERE item_id = v_drop));
        END IF;
    ELSEIF p_outcome = 'loss' THEN
        UPDATE character_stats SET deaths = deaths + 1 WHERE character_id = v_character_id;
    ELSE
        UPDATE character_stats SET battles_fled = battles_fled + 1 WHERE character_id = v_character_id;
    END IF;
END//

DELIMITER ;
