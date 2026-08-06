<?php
class AuthController extends BaseController
{
    private $db;

    public function __construct()
    {
        parent::__construct();
        $this->db = Database::getInstance()->getConnection();
    }

    public function login()
    {
        if ($this->isAuthenticated()) {
            $this->redirect(url('dashboard'));
        }

        if ($this->tryRememberedLogin()) {
            $this->redirect(url('dashboard'));
        }

        if ($this->request->getMethod() === 'POST') {
            return $this->handleLoginPost();
        }

        $this->renderLogin();
    }

    public function register()
    {
        if ($this->isAuthenticated()) {
            $this->redirect(url('dashboard'));
        }

        if ($this->request->getMethod() === 'POST') {
            return $this->handleRegisterPost();
        }

        $this->renderRegister();
    }

    public function logout()
    {
        if ($this->isAuthenticated()) {
            $this->deactivateSessionRecord();
        }

        $this->clearAuthState();
        $this->redirect(url('login'));
    }

    public function forgotPassword()
    {
        if ($this->isAuthenticated()) {
            $this->redirect(url('dashboard'));
        }

        if ($this->request->getMethod() === 'POST') {
            return $this->handleForgotPasswordPost();
        }

        $this->view('auth/forgot-password', [
            'title' => 'Forgot Password',
            'errors' => [],
            'success' => null,
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    public function resetPassword()
    {
        if ($this->isAuthenticated()) {
            $this->redirect(url('dashboard'));
        }

        $token = $this->request->get('token', $this->request->post('token', ''));
        if ($token === '') {
            $this->view('auth/reset-password', [
                'title' => 'Reset Password',
                'errors' => ['A reset token is required.'],
                'success' => null,
                'token' => '',
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        if ($this->request->getMethod() === 'POST') {
            return $this->handleResetPasswordPost($token);
        }

        $this->view('auth/reset-password', [
            'title' => 'Reset Password',
            'errors' => [],
            'success' => null,
            'token' => $token,
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    public function verifyEmail()
    {
        $token = $this->request->get('token', '');
        if ($token === '') {
            $this->view('auth/verify', [
                'title' => 'Email Verification',
                'message' => 'A verification token is required.',
                'success' => false,
            ]);
            return;
        }

        $stmt = $this->db->prepare('SELECT user_id, expires_at, verified_at FROM email_verifications WHERE token_hash = :token_hash AND is_deleted = 0 ORDER BY id DESC LIMIT 1');
        $stmt->execute([':token_hash' => hash('sha256', $token)]);
        $record = $stmt->fetch();

        if (!$record) {
            $this->view('auth/verify', [
                'title' => 'Email Verification',
                'message' => 'This verification link is invalid or has already been used.',
                'success' => false,
            ]);
            return;
        }

        if (!empty($record['verified_at'])) {
            $this->view('auth/verify', [
                'title' => 'Email Verification',
                'message' => 'Your email has already been verified.',
                'success' => true,
            ]);
            return;
        }

        if (strtotime($record['expires_at']) < time()) {
            $this->view('auth/verify', [
                'title' => 'Email Verification',
                'message' => 'This verification link has expired. Please request a fresh verification email.',
                'success' => false,
            ]);
            return;
        }

        $this->db->prepare('UPDATE users SET email_verified_at = NOW(), status = :status WHERE id = :id')->execute([
            ':status' => 'active',
            ':id' => $record['user_id'],
        ]);
        $this->db->prepare('UPDATE email_verifications SET verified_at = NOW(), updated_at = NOW() WHERE id = (SELECT id FROM (SELECT id FROM email_verifications WHERE token_hash = :token_hash ORDER BY id DESC LIMIT 1) AS current)')->execute([':token_hash' => hash('sha256', $token)]);

        $this->view('auth/verify', [
            'title' => 'Email Verification',
            'message' => 'Your email has been verified successfully. You can now sign in.',
            'success' => true,
        ]);
    }

    private function handleLoginPost()
    {
        if (!$this->validateCsrf()) {
            $this->renderLogin(['The security token expired. Please refresh the page and try again.'], null, ['email' => sanitizeInput($this->request->post('email', ''))]);
            return;
        }

        $email = sanitizeInput($this->request->post('email', ''));
        $password = $this->request->post('password', '');
        $remember = (bool) $this->request->post('remember', false);

        $errors = [];
        if (!isValidEmail($email)) {
            $errors[] = 'Please provide a valid email address.';
        }
        if (trim($password) === '') {
            $errors[] = 'Password is required.';
        }

        if (!empty($errors)) {
            $this->renderLogin($errors, null, ['email' => $email]);
            return;
        }

        if ($this->exceedsLoginAttempts()) {
            $this->renderLogin(['Too many login attempts. Please try again later.'], null, ['email' => $email]);
            return;
        }

        $stmt = $this->db->prepare('SELECT * FROM users WHERE email = :email AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password_hash'])) {
            $this->recordFailedLogin();
            $this->renderLogin(['We could not sign you in with those credentials.'], null, ['email' => $email]);
            return;
        }

        if (empty($user['email_verified_at']) || $user['status'] !== 'active') {
            $this->renderLogin(['Please verify your email before logging in.'], null, ['email' => $email]);
            return;
        }

        $this->clearLoginAttempts();
        $this->session->regenerateId(true);
        $this->session->set('user_id', (int) $user['id']);
        $this->session->set('user_role', $user['role']);
        $this->session->set('user_name', $user['full_name']);

        $this->db->prepare('UPDATE users SET last_login_at = NOW() WHERE id = :id')->execute([':id' => $user['id']]);
        $token = bin2hex(random_bytes(32));
        $this->db->prepare('INSERT INTO user_sessions (user_id, session_token, ip_address, user_agent, login_at, last_activity_at, is_active) VALUES (:user_id, :session_token, :ip_address, :user_agent, NOW(), NOW(), 1)')->execute([
            ':user_id' => $user['id'],
            ':session_token' => $token,
            ':ip_address' => $this->serverIp(),
            ':user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
        ]);
        $this->session->set('session_token', $token);

        if ($remember) {
            $this->setRememberCookie($token);
        } else {
            $this->clearRememberCookie();
        }

        $this->redirect(url('dashboard'));
    }

    private function handleRegisterPost()
    {
        if (!$this->validateCsrf()) {
            $this->renderRegister(['The security token expired. Please refresh the page and try again.'], null, [
                'username' => sanitizeInput($this->request->post('username', '')),
                'email' => sanitizeInput($this->request->post('email', '')),
            ]);
            return;
        }

        $username = sanitizeInput($this->request->post('username', ''));
        $email = sanitizeInput($this->request->post('email', ''));
        $password = $this->request->post('password', '');
        $passwordConfirmation = $this->request->post('password_confirmation', '');
        $terms = (bool) $this->request->post('terms', false);

        $errors = [];
        if (trim($username) === '') {
            $errors[] = 'Username is required.';
        }
        if (!isValidEmail($email)) {
            $errors[] = 'Please provide a valid email address.';
        }
        if (strlen($password) < 8) {
            $errors[] = 'Password must be at least 8 characters long.';
        }
        if ($password !== $passwordConfirmation) {
            $errors[] = 'Passwords do not match.';
        }
        if (!$terms) {
            $errors[] = 'You must accept the terms and conditions.';
        }

        if ($this->emailExists($email)) {
            $errors[] = 'This email address is already registered.';
        }
        if ($this->usernameExists($username)) {
            $errors[] = 'This username is already taken.';
        }

        if (!empty($errors)) {
            $this->renderRegister($errors, null, [
                'username' => $username,
                'email' => $email,
            ]);
            return;
        }

        $profileData = [
            'bio' => '',
            'city' => '',
            'profession' => '',
            'css_attempt' => 0,
            'daily_study_goal' => 0,
            'subjects' => [],
        ];

        $stmt = $this->db->prepare('INSERT INTO users (full_name, username, email, password_hash, role, status, bio, created_at) VALUES (:full_name, :username, :email, :password_hash, :role, :status, :bio, NOW())');
        $stmt->execute([
            ':full_name' => $username,
            ':username' => $username,
            ':email' => $email,
            ':password_hash' => password_hash($password, PASSWORD_BCRYPT),
            ':role' => 'student',
            ':status' => 'inactive',
            ':bio' => json_encode($profileData, JSON_UNESCAPED_SLASHES),
        ]);
        $userId = (int) $this->db->lastInsertId();

        $verifyToken = bin2hex(random_bytes(24));
        $this->db->prepare('INSERT INTO email_verifications (user_id, token_hash, expires_at, created_at) VALUES (:user_id, :token_hash, :expires_at, NOW())')->execute([
            ':user_id' => $userId,
            ':token_hash' => hash('sha256', $verifyToken),
            ':expires_at' => date('Y-m-d H:i:s', strtotime('+24 hours')),
        ]);

        $this->sendMail($email, 'Verify your CivilCircle account', 'Hi ' . $username . ', please verify your email by visiting ' . url('verify-email?token=' . $verifyToken));

        $this->renderRegister([], 'Your account was created. Please check your email to verify your address before logging in.', []);
    }

    private function handleForgotPasswordPost()
    {
        if (!$this->validateCsrf()) {
            $this->view('auth/forgot-password', [
                'title' => 'Forgot Password',
                'errors' => ['The security token expired. Please refresh the page and try again.'],
                'success' => null,
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        $email = sanitizeInput($this->request->post('email', ''));
        if (!isValidEmail($email)) {
            $this->view('auth/forgot-password', [
                'title' => 'Forgot Password',
                'errors' => ['Please provide a valid email address.'],
                'success' => null,
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        $stmt = $this->db->prepare('SELECT id FROM users WHERE email = :email AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':email' => $email]);
        $user = $stmt->fetch();

        if ($user) {
            $token = bin2hex(random_bytes(24));
            $this->db->prepare('INSERT INTO password_reset_tokens (user_id, token_hash, expires_at, created_at) VALUES (:user_id, :token_hash, :expires_at, NOW())')->execute([
                ':user_id' => $user['id'],
                ':token_hash' => hash('sha256', $token),
                ':expires_at' => date('Y-m-d H:i:s', strtotime('+1 hour')),
            ]);
            $this->sendMail($email, 'Reset your CivilCircle password', 'Use the following link to reset your password: ' . url('reset-password?token=' . $token));
        }

        $this->view('auth/forgot-password', [
            'title' => 'Forgot Password',
            'errors' => [],
            'success' => 'If an account exists for that email, a password reset link has been sent.',
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    private function handleResetPasswordPost($token)
    {
        if (!$this->validateCsrf()) {
            $this->view('auth/reset-password', [
                'title' => 'Reset Password',
                'errors' => ['The security token expired. Please refresh the page and try again.'],
                'success' => null,
                'token' => $token,
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        $password = $this->request->post('password', '');
        $confirm = $this->request->post('password_confirmation', '');

        if (strlen($password) < 8 || $password !== $confirm) {
            $this->view('auth/reset-password', [
                'title' => 'Reset Password',
                'errors' => ['Password must be at least 8 characters and match the confirmation.'],
                'success' => null,
                'token' => $token,
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        $stmt = $this->db->prepare('SELECT user_id, expires_at FROM password_reset_tokens WHERE token_hash = :token_hash AND used_at IS NULL AND is_deleted = 0 ORDER BY id DESC LIMIT 1');
        $stmt->execute([':token_hash' => hash('sha256', $token)]);
        $record = $stmt->fetch();

        if (!$record || strtotime($record['expires_at']) < time()) {
            $this->view('auth/reset-password', [
                'title' => 'Reset Password',
                'errors' => ['This reset link is invalid or has expired.'],
                'success' => null,
                'token' => '',
                'csrfToken' => $this->session->csrfToken(),
            ]);
            return;
        }

        $this->db->prepare('UPDATE users SET password_hash = :password_hash WHERE id = :id')->execute([
            ':password_hash' => password_hash($password, PASSWORD_BCRYPT),
            ':id' => $record['user_id'],
        ]);
        $this->db->prepare('UPDATE password_reset_tokens SET used_at = NOW(), updated_at = NOW() WHERE token_hash = :token_hash')->execute([':token_hash' => hash('sha256', $token)]);

        $this->view('auth/reset-password', [
            'title' => 'Reset Password',
            'errors' => [],
            'success' => 'Your password has been updated. You can now sign in.',
            'token' => '',
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    private function renderLogin($errors = [], $success = null, $old = [])
    {
        $this->view('auth/login', [
            'title' => 'Login',
            'errors' => $errors,
            'success' => $success,
            'old' => $old,
            'csrfToken' => $this->session->csrfToken(),
        ]);
    }

    private function renderRegister($errors = [], $success = null, $old = [])
    {
        $this->view('auth/register', [
            'title' => 'Register',
            'errors' => $errors,
            'success' => $success,
            'old' => $old,
            'csrfToken' => $this->session->csrfToken(),
        ]);
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

    private function isAuthenticated()
    {
        return AuthMiddleware::handle($this->session);
    }

    private function exceedsLoginAttempts()
    {
        $attempts = $this->session->get('login_attempts', 0);
        $lastAttempt = $this->session->get('login_attempt_last', 0);
        if ($attempts >= 5 && time() - $lastAttempt < 900) {
            return true;
        }
        return false;
    }

    private function recordFailedLogin()
    {
        $attempts = $this->session->get('login_attempts', 0) + 1;
        $this->session->set('login_attempts', $attempts);
        $this->session->set('login_attempt_last', time());
    }

    private function clearLoginAttempts()
    {
        $this->session->remove('login_attempts');
        $this->session->remove('login_attempt_last');
    }

    private function emailExists($email)
    {
        $stmt = $this->db->prepare('SELECT id FROM users WHERE email = :email AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':email' => $email]);
        return (bool) $stmt->fetch();
    }

    private function usernameExists($username)
    {
        $stmt = $this->db->prepare('SELECT id FROM users WHERE username = :username AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':username' => $username]);
        return (bool) $stmt->fetch();
    }

    private function tryRememberedLogin()
    {
        $token = $_COOKIE['remember_token'] ?? '';
        if ($token === '') {
            return false;
        }

        $stmt = $this->db->prepare('SELECT user_id FROM user_sessions WHERE session_token = :token AND is_active = 1 AND logout_at IS NULL ORDER BY id DESC LIMIT 1');
        $stmt->execute([':token' => $token]);
        $session = $stmt->fetch();
        if (!$session) {
            $this->clearRememberCookie();
            return false;
        }

        $stmt = $this->db->prepare('SELECT id, full_name, role, email_verified_at, status FROM users WHERE id = :id AND is_deleted = 0 LIMIT 1');
        $stmt->execute([':id' => $session['user_id']]);
        $user = $stmt->fetch();
        if (!$user || empty($user['email_verified_at']) || $user['status'] !== 'active') {
            $this->clearRememberCookie();
            return false;
        }

        $this->session->regenerateId(true);
        $this->session->set('user_id', (int) $user['id']);
        $this->session->set('user_role', $user['role']);
        $this->session->set('user_name', $user['full_name']);
        $this->session->set('session_token', $token);
        return true;
    }

    private function setRememberCookie($token)
    {
        $secure = strpos(Config::get('APP_URL', ''), 'https://') === 0;
        setcookie('remember_token', $token, time() + 60 * 60 * 24 * 30, '/', '', $secure, true);
    }

    private function clearRememberCookie()
    {
        $secure = strpos(Config::get('APP_URL', ''), 'https://') === 0;
        setcookie('remember_token', '', time() - 3600, '/', '', $secure, true);
    }

    private function deactivateSessionRecord()
    {
        $sessionToken = $this->session->get('session_token');
        if ($sessionToken) {
            $this->db->prepare('UPDATE user_sessions SET logout_at = NOW(), last_activity_at = NOW(), is_active = 0 WHERE session_token = :token')->execute([':token' => $sessionToken]);
        }
    }

    private function clearAuthState()
    {
        $this->clearRememberCookie();
        $this->session->remove('user_id');
        $this->session->remove('user_role');
        $this->session->remove('user_name');
        $this->session->remove('session_token');
        $this->session->destroy();
    }

    private function getOptionalSubjectOptions()
    {
        try {
            $stmt = $this->db->prepare('SELECT name FROM optional_subjects WHERE is_active = 1 AND is_deleted = 0 ORDER BY sort_order, name');
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_COLUMN);
        } catch (Throwable $e) {
            return [];
        }
    }

    private function serverIp()
    {
        return $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    }

    private function sendMail($to, $subject, $message)
    {
        $from = Config::get('MAIL_FROM', 'no-reply@civilcircle.local');
        $headers = 'From: ' . $from . "\r\n" . 'Reply-To: ' . $from . "\r\n" . 'X-Mailer: PHP/' . phpversion();

        if (function_exists('mail')) {
            @mail($to, $subject, $message, $headers);
            return true;
        }

        $logDir = dirname(__DIR__, 2) . '/storage/logs';
        if (!is_dir($logDir)) {
            mkdir($logDir, 0777, true);
        }
        $logFile = $logDir . '/auth_mail.log';
        file_put_contents($logFile, '[' . date('Y-m-d H:i:s') . '] To: ' . $to . PHP_EOL . $message . PHP_EOL . PHP_EOL, FILE_APPEND);
        return true;
    }
}
