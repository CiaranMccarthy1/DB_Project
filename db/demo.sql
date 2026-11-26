-- demo accounts and their game history (password: password)
USE java_knight_realms;

-- demo accounts, all with password 'password'
INSERT INTO users
    (user_id, username, email, password_hash)
VALUES
    (1, 'demo_alice', 'alice@example.com', '$2b$12$rX0EeihrtY2OXHJcABrJRe0EEOHrzVlkum5nQd3plrLwq6KUV/8K.'),
    (2, 'demo_bob', 'bob@example.com', '$2b$12$rX0EeihrtY2OXHJcABrJRe0EEOHrzVlkum5nQd3plrLwq6KUV/8K.'),
    (3, 'demo_cara', 'cara@example.com', '$2b$12$rX0EeihrtY2OXHJcABrJRe0EEOHrzVlkum5nQd3plrLwq6KUV/8K.');

INSERT INTO characters
    (character_id, user_id, class_id, character_name, level, xp, hp, max_hp, melee, mana, ranged, armor, speed, current_level_id, pos_x, pos_y)
VALUES
    (1, 1, 2, 'Aldric', 4, 223, 130, 130, 16, 8, 6, 14, 8, 1, 3, 2),
    (2, 1, 4, 'Mira', 1, 10, 80, 80, 6, 25, 16, 4, 11, 1, 5, 4),
    (3, 2, 6, 'Rook', 3, 102, 90, 90, 8, 14, 18, 5, 14, 1, 9, 7),
    (4, 3, 5, 'Sable', 1, 10, 95, 95, 8, 22, 10, 6, 10, 1, 16, 7);

INSERT INTO character_stats
    (character_id, enemies_killed, deaths, boss_kills, dungeons_completed, battles_won, battles_fled, items_used)
VALUES
    (1, 7, 0, 2, 1, 7, 0, 5),
    (2, 1, 2, 0, 0, 1, 1, 8),
    (3, 5, 0, 0, 1, 5, 0, 3),
    (4, 2, 1, 0, 0, 2, 1, 6);

INSERT INTO battles
    (battle_id, character_id, enemy_id, started_at, finished_at, outcome, xp_gained)
VALUES
    (1, 1, 1, '2026-11-16 10:00:00', '2026-11-16 10:02:00', 'win', 15),
    (2, 1, 2, '2026-11-16 10:05:00', '2026-11-16 10:06:00', 'win', 10),
    (3, 1, 3, '2026-11-17 09:00:00', '2026-11-17 09:01:00', 'win', 10),
    (4, 2, 1, '2026-11-17 20:00:00', '2026-11-17 20:03:00', 'loss', 0),
    (5, 3, 4, '2026-11-18 11:00:00', '2026-11-18 11:02:00', 'win', 16),
    (6, 3, 5, '2026-11-18 11:05:00', '2026-11-18 11:08:00', 'win', 22),
    (7, 4, 2, '2026-11-18 21:00:00', '2026-11-18 21:01:00', 'win', 10),
    (8, 1, 6, '2026-11-19 15:00:00', '2026-11-19 15:05:00', 'win', 70),
    (9, 2, 2, '2026-11-19 16:00:00', '2026-11-19 16:01:00', 'win', 10),
    (10, 3, 1, '2026-11-20 08:30:00', '2026-11-20 08:31:00', 'win', 15),
    (11, 4, 1, '2026-11-20 19:00:00', '2026-11-20 19:02:00', 'fled', 0),
    (12, 1, 7, '2026-11-21 14:00:00', '2026-11-21 14:06:00', 'win', 80),
    (13, 2, 4, '2026-11-21 15:00:00', '2026-11-21 15:02:00', 'fled', 0),
    (14, 3, 8, '2026-11-22 10:00:00', '2026-11-22 10:04:00', 'win', 25),
    (15, 4, 3, '2026-11-22 18:00:00', '2026-11-22 18:01:00', 'win', 10),
    (16, 1, 5, '2026-11-23 12:00:00', '2026-11-23 12:02:00', 'win', 22),
    (17, 2, 3, '2026-11-23 22:00:00', '2026-11-23 22:01:00', 'loss', 0),
    (18, 3, 9, '2026-11-24 09:00:00', '2026-11-24 09:03:00', 'win', 24),
    (19, 4, 5, '2026-11-24 20:00:00', '2026-11-24 20:03:00', 'loss', 0),
    (20, 1, 4, '2026-11-25 11:00:00', '2026-11-25 11:01:00', 'win', 16),
    (21, 2, 1, '2026-11-25 21:00:00', NULL, NULL, 0);

INSERT INTO character_inventory
    (character_id, item_id, quantity)
VALUES
    (1, 1, 3),
    (1, 2, 1),
    (2, 1, 5),
    (2, 4, 1),
    (3, 3, 2),
    (4, 2, 4),
    (4, 3, 1);
