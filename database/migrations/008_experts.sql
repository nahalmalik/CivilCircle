USE civilcircle;

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
