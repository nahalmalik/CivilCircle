<?php
class Controller
{
    protected $request;
    protected $response;
    protected $session;

    public function __construct()
    {
        $this->request = new Request();
        $this->response = new Response();
        $this->session = new Session();
    }

    protected function view($view, $data = [])
    {
        $viewFile = dirname(__DIR__, 1) . '/Views/' . str_replace('.', '/', $view) . '.php';
        if (!file_exists($viewFile)) {
            throw new Exception('View not found: ' . $view);
        }

        extract($data);
        ob_start();
        require $viewFile;
        echo ob_get_clean();
    }

    protected function redirect($url)
    {
        $this->response->redirect($url);
    }

    protected function json($data, $statusCode = 200)
    {
        $this->response->json($data, $statusCode);
    }
}
