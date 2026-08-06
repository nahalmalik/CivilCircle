CREATE DATABASE IF NOT EXISTS civilcircle
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE civilcircle;

CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(150) NOT NULL,
  username VARCHAR(50) NULL,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NULL,
  avatar_path VARCHAR(500) NULL,
  bio TEXT NULL,
  role ENUM('student','admin','super_admin') NOT NULL DEFAULT 'student',
  status ENUM('inactive','active','suspended','banned') NOT NULL DEFAULT 'inactive',
  email_verified_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_username (username),
  KEY idx_users_status (status),
  KEY idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE password_reset_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_password_reset_tokens_user_id (user_id),
  KEY idx_password_reset_tokens_expires_at (expires_at),
  CONSTRAINT fk_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE email_verifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  verified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_email_verifications_user_id (user_id),
  CONSTRAINT fk_email_verifications_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  session_token VARCHAR(255) NOT NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  login_at DATETIME NOT NULL,
  logout_at DATETIME NULL,
  last_activity_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_sessions_token (session_token),
  KEY idx_user_sessions_user_id (user_id),
  KEY idx_user_sessions_is_active (is_active),
  CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE compulsory_subjects (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_compulsory_subjects_slug (slug),
  KEY idx_compulsory_subjects_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE optional_subject_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  compulsory_subject_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_optional_subject_groups_slug (slug),
  KEY idx_optional_subject_groups_compulsory_subject_id (compulsory_subject_id),
  CONSTRAINT fk_optional_subject_groups_compulsory_subject FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE optional_subjects (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  optional_subject_group_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_optional_subjects_slug (slug),
  KEY idx_optional_subjects_group_id (optional_subject_group_id),
  CONSTRAINT fk_optional_subjects_group FOREIGN KEY (optional_subject_group_id) REFERENCES optional_subject_groups (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_selected_subjects (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  subject_type ENUM('compulsory','optional') NOT NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  selected_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_user_selected_subjects_user_id (user_id),
  KEY idx_user_selected_subjects_subject_type (subject_type),
  CONSTRAINT fk_user_selected_subjects_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_selected_subjects_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_user_selected_subjects_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_user_selected_subjects_choice CHECK ((compulsory_subject_id IS NOT NULL AND optional_subject_id IS NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE communities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  cover_image_path VARCHAR(500) NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_communities_slug (slug),
  KEY idx_communities_is_public (is_public),
  KEY idx_communities_is_active (is_active),
  CONSTRAINT fk_communities_created_by FOREIGN KEY (created_by) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE community_members (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  community_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role ENUM('member','moderator','admin') NOT NULL DEFAULT 'member',
  joined_at DATETIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_community_members_user_community (community_id, user_id),
  KEY idx_community_members_user_id (user_id),
  CONSTRAINT fk_community_members_community FOREIGN KEY (community_id) REFERENCES communities (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_community_members_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discussions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  community_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  is_pinned TINYINT(1) NOT NULL DEFAULT 0,
  is_locked TINYINT(1) NOT NULL DEFAULT 0,
  view_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_discussions_community_id (community_id),
  KEY idx_discussions_user_id (user_id),
  KEY idx_discussions_is_pinned (is_pinned),
  CONSTRAINT fk_discussions_community FOREIGN KEY (community_id) REFERENCES communities (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_discussions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discussion_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  discussion_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  parent_message_id BIGINT UNSIGNED NULL,
  message TEXT NOT NULL,
  is_edited TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_discussion_messages_discussion_id (discussion_id),
  KEY idx_discussion_messages_user_id (user_id),
  CONSTRAINT fk_discussion_messages_discussion FOREIGN KEY (discussion_id) REFERENCES discussions (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_discussion_messages_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_discussion_messages_parent FOREIGN KEY (parent_message_id) REFERENCES discussion_messages (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE questions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  is_answered TINYINT(1) NOT NULL DEFAULT 0,
  view_count INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_questions_user_id (user_id),
  KEY idx_questions_is_answered (is_answered),
  KEY idx_questions_view_count (view_count),
  CONSTRAINT fk_questions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_questions_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_questions_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_questions_subject_choice CHECK ((compulsory_subject_id IS NOT NULL AND optional_subject_id IS NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NOT NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_answers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  question_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_accepted TINYINT(1) NOT NULL DEFAULT 0,
  upvotes INT UNSIGNED NOT NULL DEFAULT 0,
  downvotes INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_question_answers_question_id (question_id),
  KEY idx_question_answers_user_id (user_id),
  CONSTRAINT fk_question_answers_question FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_question_answers_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE resource_categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_resource_categories_slug (slug),
  KEY idx_resource_categories_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE resources (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  file_path VARCHAR(500) NOT NULL,
  external_url VARCHAR(500) NULL,
  download_count INT UNSIGNED NOT NULL DEFAULT 0,
  is_featured TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_resources_category_id (category_id),
  KEY idx_resources_user_id (user_id),
  KEY idx_resources_is_featured (is_featured),
  CONSTRAINT fk_resources_category FOREIGN KEY (category_id) REFERENCES resource_categories (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_resources_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_resources_path_or_url CHECK (file_path IS NOT NULL OR external_url IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE recommended_books (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(150) NULL,
  publisher VARCHAR(150) NULL,
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  cover_image_path VARCHAR(500) NULL,
  purchase_link VARCHAR(500) NULL,
  description TEXT NULL,
  is_featured TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_recommended_books_is_featured (is_featured),
  CONSTRAINT fk_recommended_books_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_recommended_books_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_recommended_books_subject_choice CHECK ((compulsory_subject_id IS NOT NULL AND optional_subject_id IS NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NOT NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE past_papers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  exam_name VARCHAR(150) NULL,
  year INT NULL,
  paper_type VARCHAR(100) NULL,
  subject_type ENUM('compulsory','optional') NULL,
  compulsory_subject_id BIGINT UNSIGNED NULL,
  optional_subject_id BIGINT UNSIGNED NULL,
  file_path VARCHAR(500) NOT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_past_papers_year (year),
  KEY idx_past_papers_is_public (is_public),
  CONSTRAINT fk_past_papers_compulsory FOREIGN KEY (compulsory_subject_id) REFERENCES compulsory_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_past_papers_optional FOREIGN KEY (optional_subject_id) REFERENCES optional_subjects (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_past_papers_subject_choice CHECK ((compulsory_subject_id IS NOT NULL AND optional_subject_id IS NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NOT NULL) OR (compulsory_subject_id IS NULL AND optional_subject_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE mpt_categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_mpt_categories_slug (slug),
  KEY idx_mpt_categories_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mpt_mcqs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NOT NULL,
  question_text TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_option ENUM('A','B','C','D') NOT NULL,
  explanation TEXT NULL,
  difficulty_level ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_mpt_mcqs_category_id (category_id),
  KEY idx_mpt_mcqs_difficulty_level (difficulty_level),
  CONSTRAINT fk_mpt_mcqs_category FOREIGN KEY (category_id) REFERENCES mpt_categories (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mpt_quiz_results (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NULL,
  score INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL DEFAULT 0,
  correct_answers INT NOT NULL DEFAULT 0,
  percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  attempt_number INT NOT NULL DEFAULT 1,
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_mpt_quiz_results_user_id (user_id),
  KEY idx_mpt_quiz_results_category_id (category_id),
  CONSTRAINT fk_mpt_quiz_results_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_mpt_quiz_results_category FOREIGN KEY (category_id) REFERENCES mpt_categories (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_mpt_quiz_results_percentage CHECK (percentage BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE learn_from_experts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  designation VARCHAR(150) NULL,
  bio TEXT NULL,
  expertise_area VARCHAR(255) NULL,
  profile_image_path VARCHAR(500) NULL,
  youtube_url VARCHAR(500) NULL,
  is_featured TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_learn_from_experts_is_featured (is_featured)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE whatsapp_communities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  invite_link VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_whatsapp_communities_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE whatsapp_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  whatsapp_community_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  invite_link VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  admin_contact VARCHAR(150) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_whatsapp_groups_community_id (whatsapp_community_id),
  CONSTRAINT fk_whatsapp_groups_community FOREIGN KEY (whatsapp_community_id) REFERENCES whatsapp_communities (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  actor_id BIGINT UNSIGNED NULL,
  notification_type VARCHAR(100) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  link_path VARCHAR(500) NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_notifications_user_id (user_id),
  KEY idx_notifications_is_read (is_read),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_notifications_actor FOREIGN KEY (actor_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contact_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  subject VARCHAR(255) NULL,
  message TEXT NOT NULL,
  status ENUM('new','read','replied','closed') NOT NULL DEFAULT 'new',
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_contact_messages_status (status),
  KEY idx_contact_messages_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE system_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  setting_key VARCHAR(150) NOT NULL,
  setting_value TEXT NULL,
  setting_type VARCHAR(50) NOT NULL DEFAULT 'string',
  description TEXT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 0,
  updated_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_system_settings_setting_key (setting_key),
  KEY idx_system_settings_is_public (is_public),
  CONSTRAINT fk_system_settings_updated_by FOREIGN KEY (updated_by) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  admin_role ENUM('moderator','admin','super_admin') NOT NULL DEFAULT 'admin',
  permissions_json TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_admin_users_user_id (user_id),
  KEY idx_admin_users_admin_role (admin_role),
  CONSTRAINT fk_admin_users_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE activity_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_type ENUM('user','admin') NOT NULL,
  actor_id BIGINT UNSIGNED NOT NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100) NULL,
  entity_id BIGINT UNSIGNED NULL,
  details_json JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_activity_logs_actor_type_actor_id (actor_type, actor_id),
  KEY idx_activity_logs_action (action),
  KEY idx_activity_logs_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
