-- viva query pack: run against a populated java_knight_realms
USE java_knight_realms;

-- 1. proof that the tables are populated
SELECT COUNT(*) AS users FROM users;
SELECT COUNT(*) AS characters FROM characters;
SELECT COUNT(*) AS character_stats FROM character_stats;
SELECT COUNT(*) AS battles FROM battles;
SELECT COUNT(*) AS character_inventory FROM character_inventory;
SELECT COUNT(*) AS levels FROM levels;
SELECT COUNT(*) AS level_tiles FROM level_tiles;

-- 2. join across four tables: character, class, level, chapter
SELECT c.character_name, cc.class_name, c.level, c.xp,
       l.level_name, ch.chapter_name
FROM characters c
JOIN character_classes cc ON cc.class_id = c.class_id
JOIN levels l ON l.level_id = c.current_level_id
JOIN chapters ch ON ch.chapter_id = l.chapter_id
ORDER BY c.character_id;

-- 3. aggregate: battle record per character
SELECT c.character_name,
       COUNT(b.battle_id) AS battles,
       SUM(b.outcome = 'win') AS wins,
       SUM(b.outcome = 'loss') AS losses,
       SUM(b.outcome = 'fled') AS fled
FROM characters c
JOIN battles b ON b.character_id = c.character_id
GROUP BY c.character_id, c.character_name
ORDER BY wins DESC;

-- 4. HAVING: characters with at least two wins
SELECT c.character_name, COUNT(*) AS wins
FROM battles b
JOIN characters c ON c.character_id = b.character_id
WHERE b.outcome = 'win'
GROUP BY c.character_id, c.character_name
HAVING COUNT(*) >= 2;

-- 5. window function: rank enemies by XP inside each chapter
SELECT ch.chapter_name, e.enemy_name, e.xp_reward,
       RANK() OVER (PARTITION BY e.chapter_id ORDER BY e.xp_reward DESC) AS xp_rank
FROM enemies e
JOIN chapters ch ON ch.chapter_id = e.chapter_id
ORDER BY ch.chapter_name, xp_rank;

-- 6. CTE: enemy totals per chapter
WITH enemy_totals AS (
    SELECT chapter_id, COUNT(*) AS enemies, MAX(xp_reward) AS best_xp
    FROM enemies
    GROUP BY chapter_id
)
SELECT ch.chapter_name, et.enemies, et.best_xp
FROM chapters ch
JOIN enemy_totals et ON et.chapter_id = ch.chapter_id;

-- 7. subquery: characters who have beaten a boss
SELECT c.character_name
FROM characters c
WHERE c.character_id IN (
    SELECT b.character_id
    FROM battles b
    WHERE b.outcome = 'win'
      AND b.enemy_id IN (SELECT enemy_id FROM enemies WHERE is_boss = 1)
);

-- 8. join + aggregate: what each character carries
SELECT c.character_name, i.item_name, ci.quantity
FROM character_inventory ci
JOIN characters c ON c.character_id = ci.character_id
JOIN items i ON i.item_id = ci.item_id
ORDER BY c.character_name, i.item_name;

-- 9. EXPLAIN: battles by character should use idx_battles_character
EXPLAIN SELECT * FROM battles WHERE character_id = 1;
