<?php
class AuthController extends BaseController
{
    public function login()
    {
        $this->view('auth/login', [
            'title' => 'Login'
        ]);
    }

    public function dashboard()
    {
        $this->view('auth/dashboard', [
            'title' => 'Dashboard'
        ]);
    }
}
