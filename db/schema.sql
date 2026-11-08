SET default_storage_engine = InnoDB;

CREATE DATABASE IF NOT EXISTS ashen_realms
    CHARACTER SET utf8mb4;

USE ashen_realms;

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
    drop_item_id TINYINT UNSIGNED NULL
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
