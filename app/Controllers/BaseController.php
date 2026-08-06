<?php
class BaseController extends Controller
{
    protected $viewPath = '';

    protected function view($view, $data = [])
    {
        parent::view($this->viewPath . $view, $data);
    }
}
