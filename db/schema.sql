SET default_storage_engine = InnoDB;

DROP DATABASE IF EXISTS java_knight_realms;

CREATE DATABASE IF NOT EXISTS java_knight_realms;

USE java_knight_realms;

CREATE TABLE IF NOT EXISTS users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
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
    current_level_id INT UNSIGNED NULL, 
    pos_x SMALLINT UNSIGNED NULL,
    pos_y SMALLINT UNSIGNED NULL,
    steps_since_enc INT UNSIGNED NOT NULL DEFAULT 0,
    grace_steps TINYINT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS character_stats (
    character_id INT UNSIGNED PRIMARY KEY,
    enemies_killed INT UNSIGNED NOT NULL DEFAULT 0,
    deaths INT UNSIGNED NOT NULL DEFAULT 0,
    boss_kills INT UNSIGNED NOT NULL DEFAULT 0,
    dungeons_completed INT UNSIGNED NOT NULL DEFAULT 0,
    battles_won INT UNSIGNED NOT NULL DEFAULT 0,
    battles_fled INT UNSIGNED NOT NULL DEFAULT 0,
    items_used INT UNSIGNED NOT NULL DEFAULT 0
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

INSERT INTO level_tiles
    (level_id, pos_x, pos_y, tile_kind)
VALUES
    (1, 0, 0, 'wall'),
    (1, 1, 0, 'wall'),
    (1, 2, 0, 'wall'),
    (1, 3, 0, 'wall'),
    (1, 4, 0, 'wall'),
    (1, 5, 0, 'wall'),
    (1, 6, 0, 'wall'),
    (1, 7, 0, 'wall'),
    (1, 8, 0, 'wall'),
    (1, 9, 0, 'wall'),
    (1, 10, 0, 'wall'),
    (1, 11, 0, 'wall'),
    (1, 12, 0, 'wall'),
    (1, 13, 0, 'wall'),
    (1, 14, 0, 'wall'),
    (1, 15, 0, 'wall'),
    (1, 16, 0, 'wall'),
    (1, 17, 0, 'wall'),
    (1, 18, 0, 'wall'),
    (1, 19, 0, 'wall'),
    (1, 0, 1, 'wall'),
    (1, 1, 1, 'floor'),
    (1, 2, 1, 'floor'),
    (1, 3, 1, 'floor'),
    (1, 4, 1, 'floor'),
    (1, 5, 1, 'floor'),
    (1, 6, 1, 'wall'),
    (1, 7, 1, 'floor'),
    (1, 8, 1, 'floor'),
    (1, 9, 1, 'floor'),
    (1, 10, 1, 'floor'),
    (1, 11, 1, 'floor'),
    (1, 12, 1, 'floor'),
    (1, 13, 1, 'wall'),
    (1, 14, 1, 'floor'),
    (1, 15, 1, 'floor'),
    (1, 16, 1, 'floor'),
    (1, 17, 1, 'floor'),
    (1, 18, 1, 'floor'),
    (1, 19, 1, 'wall'),
    (1, 0, 2, 'wall'),
    (1, 1, 2, 'floor'),
    (1, 2, 2, 'floor'),
    (1, 3, 2, 'spawn'),
    (1, 4, 2, 'floor'),
    (1, 5, 2, 'floor'),
    (1, 6, 2, 'wall'),
    (1, 7, 2, 'floor'),
    (1, 8, 2, 'floor'),
    (1, 9, 2, 'floor'),
    (1, 10, 2, 'floor'),
    (1, 11, 2, 'floor'),
    (1, 12, 2, 'floor'),
    (1, 13, 2, 'wall'),
    (1, 14, 2, 'floor'),
    (1, 15, 2, 'floor'),
    (1, 16, 2, 'floor'),
    (1, 17, 2, 'floor'),
    (1, 18, 2, 'floor'),
    (1, 19, 2, 'wall'),
    (1, 0, 3, 'wall'),
    (1, 1, 3, 'floor'),
    (1, 2, 3, 'floor'),
    (1, 3, 3, 'floor'),
    (1, 4, 3, 'floor'),
    (1, 5, 3, 'floor'),
    (1, 6, 3, 'wall'),
    (1, 7, 3, 'floor'),
    (1, 8, 3, 'floor'),
    (1, 9, 3, 'floor'),
    (1, 10, 3, 'floor'),
    (1, 11, 3, 'floor'),
    (1, 12, 3, 'floor'),
    (1, 13, 3, 'wall'),
    (1, 14, 3, 'floor'),
    (1, 15, 3, 'floor'),
    (1, 16, 3, 'floor'),
    (1, 17, 3, 'floor'),
    (1, 18, 3, 'floor'),
    (1, 19, 3, 'wall'),
    (1, 0, 4, 'wall'),
    (1, 1, 4, 'floor'),
    (1, 2, 4, 'floor'),
    (1, 3, 4, 'floor'),
    (1, 4, 4, 'floor'),
    (1, 5, 4, 'floor'),
    (1, 6, 4, 'floor'),
    (1, 7, 4, 'floor'),
    (1, 8, 4, 'floor'),
    (1, 9, 4, 'floor'),
    (1, 10, 4, 'floor'),
    (1, 11, 4, 'floor'),
    (1, 12, 4, 'floor'),
    (1, 13, 4, 'floor'),
    (1, 14, 4, 'floor'),
    (1, 15, 4, 'floor'),
    (1, 16, 4, 'floor'),
    (1, 17, 4, 'floor'),
    (1, 18, 4, 'floor'),
    (1, 19, 4, 'wall'),
    (1, 0, 5, 'wall'),
    (1, 1, 5, 'floor'),
    (1, 2, 5, 'floor'),
    (1, 3, 5, 'floor'),
    (1, 4, 5, 'floor'),
    (1, 5, 5, 'floor'),
    (1, 6, 5, 'wall'),
    (1, 7, 5, 'floor'),
    (1, 8, 5, 'floor'),
    (1, 9, 5, 'floor'),
    (1, 10, 5, 'floor'),
    (1, 11, 5, 'floor'),
    (1, 12, 5, 'floor'),
    (1, 13, 5, 'wall'),
    (1, 14, 5, 'floor'),
    (1, 15, 5, 'floor'),
    (1, 16, 5, 'floor'),
    (1, 17, 5, 'floor'),
    (1, 18, 5, 'floor'),
    (1, 19, 5, 'door'),
    (1, 0, 6, 'wall'),
    (1, 1, 6, 'floor'),
    (1, 2, 6, 'floor'),
    (1, 3, 6, 'floor'),
    (1, 4, 6, 'floor'),
    (1, 5, 6, 'floor'),
    (1, 6, 6, 'wall'),
    (1, 7, 6, 'floor'),
    (1, 8, 6, 'floor'),
    (1, 9, 6, 'floor'),
    (1, 10, 6, 'floor'),
    (1, 11, 6, 'floor'),
    (1, 12, 6, 'floor'),
    (1, 13, 6, 'wall'),
    (1, 14, 6, 'floor'),
    (1, 15, 6, 'floor'),
    (1, 16, 6, 'floor'),
    (1, 17, 6, 'floor'),
    (1, 18, 6, 'floor'),
    (1, 19, 6, 'wall'),
    (1, 0, 7, 'wall'),
    (1, 1, 7, 'floor'),
    (1, 2, 7, 'floor'),
    (1, 3, 7, 'floor'),
    (1, 4, 7, 'floor'),
    (1, 5, 7, 'floor'),
    (1, 6, 7, 'wall'),
    (1, 7, 7, 'floor'),
    (1, 8, 7, 'floor'),
    (1, 9, 7, 'floor'),
    (1, 10, 7, 'floor'),
    (1, 11, 7, 'floor'),
    (1, 12, 7, 'floor'),
    (1, 13, 7, 'wall'),
    (1, 14, 7, 'floor'),
    (1, 15, 7, 'floor'),
    (1, 16, 7, 'floor'),
    (1, 17, 7, 'floor'),
    (1, 18, 7, 'floor'),
    (1, 19, 7, 'wall'),
    (1, 0, 8, 'wall'),
    (1, 1, 8, 'floor'),
    (1, 2, 8, 'floor'),
    (1, 3, 8, 'floor'),
    (1, 4, 8, 'floor'),
    (1, 5, 8, 'floor'),
    (1, 6, 8, 'wall'),
    (1, 7, 8, 'floor'),
    (1, 8, 8, 'floor'),
    (1, 9, 8, 'floor'),
    (1, 10, 8, 'floor'),
    (1, 11, 8, 'floor'),
    (1, 12, 8, 'floor'),
    (1, 13, 8, 'wall'),
    (1, 14, 8, 'floor'),
    (1, 15, 8, 'floor'),
    (1, 16, 8, 'floor'),
    (1, 17, 8, 'floor'),
    (1, 18, 8, 'floor'),
    (1, 19, 8, 'wall'),
    (1, 0, 9, 'wall'),
    (1, 1, 9, 'floor'),
    (1, 2, 9, 'floor'),
    (1, 3, 9, 'floor'),
    (1, 4, 9, 'floor'),
    (1, 5, 9, 'floor'),
    (1, 6, 9, 'wall'),
    (1, 7, 9, 'floor'),
    (1, 8, 9, 'floor'),
    (1, 9, 9, 'floor'),
    (1, 10, 9, 'floor'),
    (1, 11, 9, 'floor'),
    (1, 12, 9, 'floor'),
    (1, 13, 9, 'wall'),
    (1, 14, 9, 'floor'),
    (1, 15, 9, 'floor'),
    (1, 16, 9, 'floor'),
    (1, 17, 9, 'floor'),
    (1, 18, 9, 'floor'),
    (1, 19, 9, 'wall'),
    (1, 0, 10, 'wall'),
    (1, 1, 10, 'wall'),
    (1, 2, 10, 'wall'),
    (1, 3, 10, 'wall'),
    (1, 4, 10, 'wall'),
    (1, 5, 10, 'wall'),
    (1, 6, 10, 'wall'),
    (1, 7, 10, 'wall'),
    (1, 8, 10, 'wall'),
    (1, 9, 10, 'wall'),
    (1, 10, 10, 'wall'),
    (1, 11, 10, 'wall'),
    (1, 12, 10, 'wall'),
    (1, 13, 10, 'wall'),
    (1, 14, 10, 'wall'),
    (1, 15, 10, 'wall'),
    (1, 16, 10, 'wall'),
    (1, 17, 10, 'wall'),
    (1, 18, 10, 'wall'),
    (1, 19, 10, 'wall');

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
