SET default_storage_engine = InnoDB;

DROP DATABASE IF EXISTS java_knight_realms;

CREATE DATABASE IF NOT EXISTS java_knight_realms;

USE java_knight_realms;

CREATE TABLE IF NOT EXISTS users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS character_classes (
    class_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    base_hp SMALLINT UNSIGNED NOT NULL,
    base_melee SMALLINT UNSIGNED NOT NULL,
    base_mana SMALLINT UNSIGNED NOT NULL,
    base_ranged SMALLINT UNSIGNED NOT NULL,
    base_armor SMALLINT UNSIGNED NOT NULL,
    base_speed SMALLINT UNSIGNED NOT NULL,
    attack_a_kind ENUM ('melee', 'ranged', 'magic') NOT NULL,
    attack_b_kind ENUM ('melee', 'ranged', 'magic', 'melee_aoe', 'magic_strong', 'heal') NOT NULL
);

CREATE TABLE IF NOT EXISTS items (
    item_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    sprite VARCHAR(50) NOT NULL,
    effect ENUM ('heal_hp', 'heal_hp_large') NOT NULL,
    effect_value SMALLINT UNSIGNED NOT NULL,
    max_stack SMALLINT UNSIGNED NOT NULL DEFAULT 99
);

CREATE TABLE IF NOT EXISTS chapters (
    chapter_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    chapter_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS levels (
    level_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    chapter_id TINYINT UNSIGNED NOT NULL,
    level_name VARCHAR(50) NOT NULL,
    width TINYINT UNSIGNED NOT NULL,
    height TINYINT UNSIGNED NOT NULL,
    CONSTRAINT fk_levels_chapter FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
);

CREATE TABLE IF NOT EXISTS characters (
    character_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    class_id TINYINT UNSIGNED NOT NULL,
    character_name VARCHAR(50) NOT NULL,
    level SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    xp INT UNSIGNED NOT NULL DEFAULT 0,
    hp SMALLINT UNSIGNED NOT NULL,
    max_hp SMALLINT UNSIGNED NOT NULL,
    melee SMALLINT UNSIGNED NOT NULL,
    mana SMALLINT UNSIGNED NOT NULL,
    ranged SMALLINT UNSIGNED NOT NULL,
    armor SMALLINT UNSIGNED NOT NULL,
    speed SMALLINT UNSIGNED NOT NULL,
    current_level_id SMALLINT UNSIGNED NULL,
    pos_x SMALLINT UNSIGNED NULL,
    pos_y SMALLINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_characters_name UNIQUE (user_id, character_name),
    CONSTRAINT chk_characters_hp CHECK (hp <= max_hp),
    CONSTRAINT chk_characters_level CHECK (level >= 1),
    CONSTRAINT fk_characters_user FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_characters_class FOREIGN KEY (class_id) REFERENCES character_classes (class_id),
    CONSTRAINT fk_characters_level FOREIGN KEY (current_level_id) REFERENCES levels (level_id)
);

CREATE TABLE IF NOT EXISTS character_stats (
    character_id INT UNSIGNED PRIMARY KEY,
    enemies_killed INT UNSIGNED NOT NULL DEFAULT 0,
    deaths INT UNSIGNED NOT NULL DEFAULT 0,
    boss_kills INT UNSIGNED NOT NULL DEFAULT 0,
    dungeons_completed INT UNSIGNED NOT NULL DEFAULT 0,
    battles_won INT UNSIGNED NOT NULL DEFAULT 0,
    battles_fled INT UNSIGNED NOT NULL DEFAULT 0,
    items_used INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_character_stats_character FOREIGN KEY (character_id) REFERENCES characters (character_id)
);

CREATE TABLE IF NOT EXISTS level_tiles (
    level_id SMALLINT UNSIGNED NOT NULL,
    pos_x TINYINT UNSIGNED NOT NULL,
    pos_y TINYINT UNSIGNED NOT NULL,
    tile_kind ENUM('floor', 'wall', 'spawn', 'door') NOT NULL,
    PRIMARY KEY (level_id, pos_x, pos_y),
    CONSTRAINT fk_level_tiles_level FOREIGN KEY (level_id) REFERENCES levels (level_id)
);

CREATE TABLE IF NOT EXISTS enemy_types (
    enemy_type_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS enemies (
    enemy_id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enemy_name VARCHAR(50) NOT NULL,
    enemy_type_id TINYINT UNSIGNED NOT NULL,
    chapter_id TINYINT UNSIGNED NOT NULL, 
    is_boss BOOLEAN NOT NULL DEFAULT FALSE,
    hp SMALLINT UNSIGNED NOT NULL,
    melee SMALLINT UNSIGNED NOT NULL,
    mana SMALLINT UNSIGNED NOT NULL,
    ranged SMALLINT UNSIGNED NOT NULL,
    armor SMALLINT UNSIGNED NOT NULL,
    speed SMALLINT UNSIGNED NOT NULL,
    xp_reward INT UNSIGNED NOT NULL,
    drop_item_id TINYINT UNSIGNED NULL,
    CONSTRAINT fk_enemies_chapter FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
);

CREATE TABLE IF NOT EXISTS battles (
    battle_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    character_id INT UNSIGNED NOT NULL,
    enemy_id TINYINT UNSIGNED NOT NULL,
    started_at DATETIME NOT NULL,
    finished_at DATETIME NULL,
    outcome ENUM('win', 'loss', 'fled') NULL,
    xp_gained INT UNSIGNED NOT NULL DEFAULT 0,
    INDEX idx_battles_character (character_id),
    CONSTRAINT fk_battles_character FOREIGN KEY (character_id) REFERENCES characters (character_id),
    CONSTRAINT fk_battles_enemy FOREIGN KEY (enemy_id) REFERENCES enemies (enemy_id)
);

CREATE TABLE IF NOT EXISTS character_inventory (
    character_id INT UNSIGNED NOT NULL,
    item_id TINYINT UNSIGNED NOT NULL,
    quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (character_id, item_id),
    CONSTRAINT fk_inventory_character FOREIGN KEY (character_id) REFERENCES characters (character_id),
    CONSTRAINT fk_inventory_item FOREIGN KEY (item_id) REFERENCES items (item_id),
    CONSTRAINT chk_inventory_quantity CHECK (quantity > 0)
);

-- creates character classes 
INSERT INTO character_classes
    (class_id, class_name, description, base_hp, base_melee, base_mana, base_ranged, base_armor, base_speed, attack_a_kind, attack_b_kind)
VALUES
    (1, 'Soldier', 'Sword and bow', 110, 14, 10, 12, 8, 10, 'melee', 'ranged'),
    (2, 'Knight', 'Sword and area attack', 130, 16, 8, 6, 14, 8, 'melee', 'melee_aoe'),
    (3, 'Templar', 'Sword and area attack', 120, 15, 12, 6, 12, 9, 'melee', 'melee_aoe'),
    (4, 'Wizard', 'Two mana attacks', 80, 6, 25, 16, 4, 11, 'magic', 'magic_strong'),
    (5, 'Priest', 'Mana and heal', 95, 8, 22, 10, 6, 10, 'magic', 'heal'),
    (6, 'Archer', 'Bow and mana shot', 90, 8, 14, 18, 5, 14, 'ranged', 'magic');

-- creates items
INSERT INTO items
    (item_id, item_name, sprite, effect, effect_value, max_stack)
VALUES
    (1, 'Red Potion', 'potion_red', 'heal_hp', 50, 99),
    (2, 'Green Potion', 'potion_green', 'heal_hp', 100, 99),
    (3, 'Blue Potion', 'potion_blue', 'heal_hp_large', 150, 99),
    (4, 'Purple Potion', 'potion_purple', 'heal_hp_large', 250, 99);

INSERT INTO enemy_types
    (enemy_type_id, type_name)
VALUES
    (1, 'humanoid'),
    (2, 'beast'),
    (3, 'undead'),
    (4, 'demon'),
    (5, 'ooze'),
    (6, 'construct');

INSERT INTO chapters
    (chapter_id, chapter_name)
VALUES
    (1, 'The Keep'),
    (2, 'The Depths');

INSERT INTO levels
    (level_id, chapter_id, level_name, width, height)
VALUES
    (1, 1, 'The Keep', 20, 11);

INSERT INTO enemies
    (enemy_id, enemy_name, enemy_type_id, chapter_id, is_boss, hp, melee, mana, ranged, armor, speed, xp_reward, drop_item_id)
VALUES
    (1, 'Orc', 1, 1, 0, 55, 12, 0, 4, 5, 10, 15, NULL),
    (2, 'Slime', 5, 1, 0, 45, 6, 0, 0, 3, 6, 10, NULL),
    (3, 'Bat', 2, 1, 0, 35, 7, 0, 6, 1, 16, 10, NULL),
    (4, 'Skeleton Archer', 3, 1, 0, 50, 6, 0, 12, 3, 11, 16, NULL),
    (5, 'Orc Rider', 1, 1, 0, 70, 15, 0, 0, 6, 13, 22, NULL),
    (6, 'Elite Orc', 1, 1, 1, 140, 20, 0, 6, 10, 11, 70, 1),
    (7, 'Necromancer', 1, 1, 1, 120, 8, 22, 0, 8, 12, 80, 2),
    (8, 'Demon', 4, 2, 0, 75, 14, 8, 0, 7, 11, 25, NULL),
    (9, 'Flying Demon', 4, 2, 0, 65, 8, 10, 10, 5, 15, 24, NULL),
    (10, 'Hell Hound', 4, 2, 0, 85, 16, 0, 0, 8, 13, 28, NULL),
    (11, 'Hell Bat', 4, 2, 0, 55, 8, 12, 8, 4, 17, 22, NULL),
    (12, 'Black Knight on Horse', 3, 2, 1, 200, 24, 0, 0, 16, 10, 140, 3),
    (13, 'Flame Golem', 6, 2, 1, 240, 20, 0, 0, 20, 7, 160, 3),
    (14, 'Warlock', 1, 2, 1, 180, 10, 26, 10, 10, 12, 180, 4);

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

