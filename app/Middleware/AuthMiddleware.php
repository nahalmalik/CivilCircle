<?php
class AuthMiddleware
{
    public static function handle(Session $session)
    {
        return (bool) $session->get('user_id');
    }
}
