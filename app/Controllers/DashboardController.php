<?php
class DashboardController extends BaseController
{
    public function index()
    {
        if (!AuthMiddleware::handle($this->session)) {
            $this->redirect(url('login'));
            return;
        }

        $this->view('dashboard', [
            'title' => 'Dashboard',
            'message' => 'Welcome to your dashboard.'
        ]);
    }
}
