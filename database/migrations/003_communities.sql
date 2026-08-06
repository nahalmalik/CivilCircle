USE civilcircle;

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
