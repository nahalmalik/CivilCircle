<?php
class Response
{
    public function json($data, $statusCode = 200)
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data, JSON_UNESCAPED_SLASHES);
    }

    public function redirect($url)
    {
        header('Location: ' . $url);
        exit;
    }

    public function setStatusCode($code)
    {
        http_response_code($code);
    }
}
