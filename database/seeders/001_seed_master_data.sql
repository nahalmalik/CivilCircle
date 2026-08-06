USE civilcircle;

INSERT INTO compulsory_subjects (name, slug, description, sort_order, is_active) VALUES
('English Essay', 'english-essay', 'English essay and composition preparation', 1, 1),
('English Precis & Composition', 'english-precis-composition', 'English precis and composition practice', 2, 1),
('General Knowledge', 'general-knowledge', 'General knowledge and current affairs', 3, 1),
('Pakistan Affairs', 'pakistan-affairs', 'Pakistan affairs and constitutional studies', 4, 1),
('Current Affairs', 'current-affairs', 'Current national and international affairs', 5, 1),
('Islamic Studies', 'islamic-studies', 'Islamic studies for CSS preparation', 6, 1);

INSERT INTO optional_subject_groups (compulsory_subject_id, name, slug, description, sort_order, is_active) VALUES
(1, 'Literature', 'literature', 'Literature optional subjects', 1, 1),
(2, 'Social Sciences', 'social-sciences', 'Social sciences optional subjects', 2, 1),
(3, 'Administration', 'administration', 'Administration and governance optional subjects', 3, 1),
(4, 'Law', 'law', 'Law related optional subjects', 4, 1);

INSERT INTO optional_subjects (optional_subject_group_id, name, slug, description, sort_order, is_active) VALUES
(1, 'English Literature', 'english-literature', 'Study of English literature', 1, 1),
(1, 'Urdu Literature', 'urdu-literature', 'Study of Urdu literature', 2, 1),
(2, 'Sociology', 'sociology', 'Sociology for CSS aspirants', 3, 1),
(2, 'Psychology', 'psychology', 'Psychology optional subject', 4, 1),
(3, 'Public Administration', 'public-administration', 'Public administration subject', 5, 1),
(3, 'Political Science', 'political-science', 'Political science subject', 6, 1),
(4, 'International Law', 'international-law', 'International law subject', 7, 1),
(4, 'Constitutional Law', 'constitutional-law', 'Constitutional law subject', 8, 1);

INSERT INTO resource_categories (name, slug, description, is_active) VALUES
('Notes', 'notes', 'Study notes and summaries', 1),
('PDFs', 'pdfs', 'PDF documents and handouts', 1),
('Videos', 'videos', 'Educational video resources', 1),
('Templates', 'templates', 'Useful templates and formats', 1);

INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('site_name', 'CivilCircle', 'string', 'Platform display name', 1),
('site_tagline', 'By Aspirants, For Aspirants', 'string', 'Platform tagline', 1),
('default_role', 'student', 'string', 'Default role for new users', 1),
('allow_registration', '1', 'boolean', 'Whether registration is enabled', 1);
