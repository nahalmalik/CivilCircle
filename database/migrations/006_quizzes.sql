USE civilcircle;

CREATE TABLE weekly_vocabulary_quizzes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  starts_at DATETIME NOT NULL,
  ends_at DATETIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_weekly_vocabulary_quizzes_starts_at (starts_at),
  KEY idx_weekly_vocabulary_quizzes_is_active (is_active),
  CONSTRAINT fk_weekly_vocabulary_quizzes_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_weekly_vocabulary_quizzes_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_weekly_vocabulary_quizzes_dates CHECK (ends_at > starts_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE weekly_quiz_questions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quiz_id BIGINT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  question_type ENUM('mcq','short_answer') NOT NULL DEFAULT 'mcq',
  points INT NOT NULL DEFAULT 1,
  explanation TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_weekly_quiz_questions_quiz_id (quiz_id),
  CONSTRAINT fk_weekly_quiz_questions_quiz FOREIGN KEY (quiz_id) REFERENCES weekly_vocabulary_quizzes (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE weekly_quiz_answers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  question_id BIGINT UNSIGNED NOT NULL,
  answer_text TEXT NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_weekly_quiz_answers_question_id (question_id),
  CONSTRAINT fk_weekly_quiz_answers_question FOREIGN KEY (question_id) REFERENCES weekly_quiz_questions (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_weekly_quiz_results (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  quiz_id BIGINT UNSIGNED NOT NULL,
  score INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL DEFAULT 0,
  percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  attempt_number INT NOT NULL DEFAULT 1,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_user_weekly_quiz_results_user_id (user_id),
  KEY idx_user_weekly_quiz_results_quiz_id (quiz_id),
  CONSTRAINT fk_user_weekly_quiz_results_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_weekly_quiz_results_quiz FOREIGN KEY (quiz_id) REFERENCES weekly_vocabulary_quizzes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_user_weekly_quiz_results_percentage CHECK (percentage BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
