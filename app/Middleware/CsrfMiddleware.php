<?php
class CsrfMiddleware
{
    public static function handle(Request $request, Session $session)
    {
        if ($request->getMethod() === 'POST') {
            $token = $request->post('_csrf_token');
            if (!$session->validateCsrf($token)) {
                throw new Exception('CSRF token validation failed');
            }
        }
    }
}
