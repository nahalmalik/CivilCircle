USE civilcircle;

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
