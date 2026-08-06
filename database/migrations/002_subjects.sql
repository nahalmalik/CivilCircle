USE civilcircle;

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
