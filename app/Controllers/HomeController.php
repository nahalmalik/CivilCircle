<?php
class HomeController extends BaseController
{
    public function index()
    {
        $this->view('home', [
            'title' => 'Welcome to CivilCircle',
            'message' => 'Core MVC foundation is ready.'
        ]);
    }

    public function test()
    {
        echo 'Test route working';
    }
}
