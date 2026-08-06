<?php
class Session
{
    public function __construct()
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_set_cookie_params([
                'lifetime' => 0,
                'path' => '/',
                'secure' => false,
                'httponly' => true,
                'samesite' => 'Lax'
            ]);
            session_start();
        }
    }

    public function set($key, $value)
    {
        $_SESSION[$key] = $value;
    }

    public function get($key, $default = null)
    {
        return $_SESSION[$key] ?? $default;
    }

    public function remove($key)
    {
        unset($_SESSION[$key]);
    }

    public function destroy()
    {
        session_destroy();
    }

    public function regenerateId($deleteOldSession = true)
    {
        session_regenerate_id($deleteOldSession);
    }

    public function csrfToken()
    {
        if (!$this->get('_csrf_token')) {
            $this->set('_csrf_token', bin2hex(random_bytes(32)));
        }

        return $this->get('_csrf_token');
    }

    public function validateCsrf($token)
    {
        return hash_equals($this->csrfToken(), (string) $token);
    }
}
