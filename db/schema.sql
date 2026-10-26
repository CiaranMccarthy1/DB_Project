CREATE DATABASE IF NOT EXISTS Ashen;

create table if not exists user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

create table if not exists enemies (
    enemy_id INT AUTO_INCREMENT PRIMARY KEY,
    enemy_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    health INT NOT NULL,
    attack INT NOT NULL,
    attack_a_kind ENUM('melee', 'ranged', 'magic') NOT NULL,
    attack_b_kind ENUM('melee', 'ranged', 'magic') NOT NULL

);

create table if not exists charater (
    class_id FOREIGN KEY REFERENCES class(class_id),
    level INT NOT NULL,
    xp INT NOT NULL,
    user_id UNIQUE FOREIGN KEY REFERENCES user(user_id),
    current_level_id FOREIGN KEY REFERENCES level(level_id) NULL,
    steps_since_enc INT NOT NULL,
    grace_steps INT NOT NULL
);

create table if not exists class (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    base_health INT NOT NULL,
    base_attack INT NOT NULL,
    attack_a_kind ENUM('melee', 'ranged', 'magic') NOT NULL,
    attack_b_kind ENUM('melee', 'ranged', 'magic') NOT NULL
);

create table if not exists character_stats (
    character_id UNIQUE FOREIGN KEY REFERENCES charater(character_id),
    playtime_seconds INT NOT NULL,
    total_xp INT NOT NULL,
    total_steps INT NOT NULL,
    enemies_defeated INT NOT NULL
);
