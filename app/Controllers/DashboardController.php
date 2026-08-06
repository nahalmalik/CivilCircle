<?php
class DashboardController extends BaseController
{
    public function index()
    {
        $this->view('dashboard', [
            'title' => 'Dashboard',
            'message' => 'Welcome to your dashboard.'
        ]);
    }
}
