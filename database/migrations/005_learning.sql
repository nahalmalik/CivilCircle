USE civilcircle;

CREATE TABLE vocabulary (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  word VARCHAR(150) NOT NULL,
  meaning TEXT NOT NULL,
  example TEXT NULL,
  difficulty_level ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy',
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_vocabulary_word (word),
  KEY idx_vocabulary_difficulty_level (difficulty_level),
  CONSTRAINT fk_vocabulary_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_vocabulary_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_vocabulary_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  vocabulary_id BIGINT UNSIGNED NOT NULL,
  status ENUM('not_started','learning','mastered') NOT NULL DEFAULT 'not_started',
  mastery_level INT NOT NULL DEFAULT 0,
  last_reviewed_at DATETIME NULL,
  review_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_vocabulary_progress_user_word (user_id, vocabulary_id),
  KEY idx_user_vocabulary_progress_status (status),
  CONSTRAINT fk_user_vocabulary_progress_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_vocabulary_progress_vocabulary FOREIGN KEY (vocabulary_id) REFERENCES vocabulary (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE idioms (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  idiom VARCHAR(150) NOT NULL,
  meaning TEXT NOT NULL,
  example TEXT NULL,
  difficulty_level ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_idioms_idiom (idiom),
  KEY idx_idioms_difficulty_level (difficulty_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_idiom_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  idiom_id BIGINT UNSIGNED NOT NULL,
  status ENUM('not_started','learning','mastered') NOT NULL DEFAULT 'not_started',
  mastery_level INT NOT NULL DEFAULT 0,
  last_reviewed_at DATETIME NULL,
  review_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_idiom_progress_user_idiom (user_id, idiom_id),
  KEY idx_user_idiom_progress_status (status),
  CONSTRAINT fk_user_idiom_progress_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_idiom_progress_idiom FOREIGN KEY (idiom_id) REFERENCES idioms (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE daily_quotes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quote TEXT NOT NULL,
  author VARCHAR(150) NULL,
  category VARCHAR(100) NULL,
  published_date DATE NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_daily_quotes_published_date (published_date),
  KEY idx_daily_quotes_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE daily_reading_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  target_date DATE NOT NULL,
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_daily_reading_tasks_target_date (target_date),
  KEY idx_daily_reading_tasks_is_active (is_active),
  CONSTRAINT fk_daily_reading_tasks_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_daily_reading_tasks_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_daily_reading_tasks_subject_choice CHECK ((compulsory_subject_id IS NOT NULL AND optional_subject_id IS NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NOT NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reading_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  reading_task_id BIGINT UNSIGNED NOT NULL,
  status ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  completed_at DATETIME NULL,
  notes TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reading_progress_user_task (user_id, reading_task_id),
  KEY idx_reading_progress_status (status),
  CONSTRAINT fk_reading_progress_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_reading_progress_task FOREIGN KEY (reading_task_id) REFERENCES daily_reading_tasks (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
