<?php
class Request
{
    public function __construct()
    {
        $this->method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $this->path = $this->parsePath();
        $this->query = $_GET;
        $this->post = $_POST;
        $this->server = $_SERVER;
        $this->input = $this->getInputBody();
    }

    public function parsePath()
    {
        $requestUri = $_SERVER['REQUEST_URI'] ?? '/';
        $path = parse_url($requestUri, PHP_URL_PATH);
        $basePath = dirname($_SERVER['SCRIPT_NAME'] ?? '/');

        if ($basePath !== '/' && strpos($path, $basePath) === 0) {
            $path = substr($path, strlen($basePath));
        }

        return '/' . trim($path, '/');
    }

    public function getMethod()
    {
        return $this->method;
    }

    public function getPath()
    {
        return $this->path === '' ? '/' : $this->path;
    }

    public function get($key, $default = null)
    {
        return $this->query[$key] ?? $default;
    }

    public function post($key, $default = null)
    {
        return $this->post[$key] ?? $default;
    }

    public function input($key = null, $default = null)
    {
        if ($key === null) {
            return $this->input;
        }

        return $this->input[$key] ?? $default;
    }

    private function getInputBody()
    {
        $raw = file_get_contents('php://input');
        if ($raw === '') {
            return [];
        }

        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }
}
