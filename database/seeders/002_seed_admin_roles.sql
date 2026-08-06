USE civilcircle;

INSERT INTO admin_users (user_id, admin_role, permissions_json, is_active) VALUES
(1, 'super_admin', '{"users": true, "content": true, "settings": true, "moderation": true}', 1);
