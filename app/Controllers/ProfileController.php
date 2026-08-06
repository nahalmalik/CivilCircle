<?php
class ProfileController extends BaseController
{
    private $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getInstance()->getConnection();
    }

    public function settings()
    {
        if (!AuthMiddleware::handle($this->session)) {
            $this->redirect(url('login'));
            return;
        }

        if ($this->request->getMethod() === 'POST') {
            $this->handleSettingsPost();
            return;
        }

        $this->renderSettings();
    }

    private function renderSettings($errors = [], $success = null)
    {
        $userId = (int) $this->session->get('user_id');
        $user = $this->getUserProfile($userId);
        $groups = $this->getOptionalSubjectGroups();
        $selectedSubjectIds = $this->getSelectedSubjectIds($userId);

        $this->view('profile/settings', [
            'title' => 'Profile Settings',
            'errors' => $errors,
            'success' => $success,
            'profile' => $user,
            'subjectGroups' => $groups,
            'selectedSubjectIds' => $selectedSubjectIds,
            'selectedSubjects' => $this->getSelectedSubjectNames($userId),
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    private function handleSettingsPost()
    {
        if (!$this->validateCsrf()) {
            $this->renderSettings(['The security token expired. Please refresh the page and try again.']);
            return;
        }

        $userId = (int) $this->session->get('user_id');
        $fullName = sanitizeInput($this->request->post('full_name', ''));
        $bio = sanitizeInput($this->request->post('bio', ''));
        $city = sanitizeInput($this->request->post('city', ''));
        $profession = sanitizeInput($this->request->post('profession', ''));
        $cssAttempt = max(0, (int) $this->request->post('css_attempt', 0));
        $dailyGoal = max(0, (int) $this->request->post('daily_study_goal', 0));
        $subjectIds = $this->request->post('subjects', []);
        if (!is_array($subjectIds)) {
            $subjectIds = [$subjectIds];
        }

        $errors = [];
        if (trim($fullName) === '') {
            $errors[] = 'Full name is required.';
        }

        if (!empty($errors)) {
            $this->renderSettings($errors);
            return;
        }

        $profileData = [
            'full_name' => $fullName,
            'bio' => $bio,
            'city' => $city,
            'profession' => $profession,
            'css_attempt' => $cssAttempt,
            'daily_study_goal' => $dailyGoal,
            'subjects' => $subjectIds,
        ];

        $this->db->prepare('UPDATE users SET full_name = :full_name, bio = :bio, updated_at = NOW() WHERE id = :id')->execute([
            ':full_name' => $fullName,
            ':bio' => json_encode($profileData, JSON_UNESCAPED_SLASHES),
            ':id' => $userId,
        ]);

        $this->saveSelectedSubjects($userId, $subjectIds);
        $this->session->set('user_name', $fullName);

        $this->renderSettings([], 'Your profile has been updated successfully.');
    }

    private function saveSelectedSubjects($userId, array $subjectIds)
    {
        $this->db->prepare('DELETE FROM user_selected_subjects WHERE user_id = :user_id AND is_deleted = 0')->execute([':user_id' => $userId]);

        $validIds = array_filter(array_map('intval', $subjectIds));
        foreach ($validIds as $optionalSubjectId) {
            $subjectStmt = $this->db->prepare('SELECT id FROM optional_subjects WHERE id = :id AND is_active = 1 AND is_deleted = 0 LIMIT 1');
            $subjectStmt->execute([':id' => $optionalSubjectId]);
            $subject = $subjectStmt->fetch();
            if ($subject) {
                $this->db->prepare('INSERT INTO user_selected_subjects (user_id, subject_type, optional_subject_id, selected_at, created_at) VALUES (:user_id, :subject_type, :optional_subject_id, NOW(), NOW())')->execute([
                    ':user_id' => $userId,
                    ':subject_type' => 'optional',
                    ':optional_subject_id' => $subject['id'],
                ]);
            }
        }
    }

    private function getUserProfile($userId)
    {
        $stmt = $this->db->prepare('SELECT id, full_name, username, email, bio, avatar_path FROM users WHERE id = :id AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':id' => $userId]);
        $user = $stmt->fetch();
        if (!$user) {
            return [];
        }

        $decoded = json_decode((string) $user['bio'], true);
        if (!is_array($decoded)) {
            $decoded = [];
        }

        return [
            'id' => (int) $user['id'],
            'full_name' => $user['full_name'] ?? '',
            'username' => $user['username'] ?? '',
            'email' => $user['email'] ?? '',
            'bio' => $decoded['bio'] ?? '',
            'city' => $decoded['city'] ?? '',
            'profession' => $decoded['profession'] ?? '',
            'css_attempt' => $decoded['css_attempt'] ?? 0,
            'daily_study_goal' => $decoded['daily_study_goal'] ?? 0,
            'avatar_path' => $user['avatar_path'] ?? '',
        ];
    }

    private function getOptionalSubjectGroups()
    {
        $stmt = $this->db->prepare('SELECT og.id, og.name, og.description, og.slug FROM optional_subject_groups og WHERE og.is_active = 1 AND og.is_deleted = 0 ORDER BY og.sort_order, og.id');
        $stmt->execute();
        $groups = $stmt->fetchAll();

        $result = [];
        foreach ($groups as $group) {
            $subjectStmt = $this->db->prepare('SELECT id, name, description FROM optional_subjects WHERE optional_subject_group_id = :group_id AND is_active = 1 AND is_deleted = 0 ORDER BY sort_order, id');
            $subjectStmt->execute([':group_id' => $group['id']]);
            $subjects = $subjectStmt->fetchAll();

            $groupRule = 'one';
            $maxSelections = 1;
            $marksLabel = 'One 200-mark subject';
            $groupId = (int) $group['id'];
            if ($groupId === 2) {
                $groupRule = 'group2-100-marks';
                $maxSelections = 2;
                $marksLabel = 'One 200-mark subject OR two 100-mark subjects';
            } elseif ($groupId === 3 || $groupId === 4 || $groupId === 5 || $groupId === 6 || $groupId === 7) {
                $groupRule = 'one';
                $maxSelections = 1;
                $marksLabel = 'One subject';
            }

            foreach ($subjects as &$subject) {
                $subject['marks'] = $groupId === 2 && in_array((int) $subject['id'], [16, 17], true) ? 200 : 100;
            }
            unset($subject);

            $result[] = [
                'id' => (int) $group['id'],
                'name' => $group['name'],
                'description' => $group['description'],
                'max_selections' => $maxSelections,
                'rule' => $groupRule,
                'marks_label' => $marksLabel,
                'subjects' => $subjects,
            ];
        }

        return $result;
    }

    private function getSelectedSubjectIds($userId)
    {
        $stmt = $this->db->prepare('SELECT optional_subject_id FROM user_selected_subjects WHERE user_id = :user_id AND is_deleted = 0 AND optional_subject_id IS NOT NULL ORDER BY id');
        $stmt->execute([':user_id' => $userId]);
        return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
    }

    private function getSelectedSubjectNames($userId)
    {
        $ids = $this->getSelectedSubjectIds($userId);
        if (empty($ids)) {
            return [];
        }
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $stmt = $this->db->prepare('SELECT name FROM optional_subjects WHERE id IN (' . $placeholders . ')');
        $stmt->execute($ids);
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    private function validateCsrf()
    {
        try {
            CsrfMiddleware::handle($this->request, $this->session);
            return true;
        } catch (Exception $e) {
            return false;
        }
    }
}
