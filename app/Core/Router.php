<?php
class Router
{
    private $routes = [];
    private $errorHandler;

    public function __construct($errorHandler = null)
    {
        $this->errorHandler = $errorHandler;
    }

    public function get($path, $handler)
    {
        $this->routes['GET'][$this->normalizePath($path)] = $handler;
    }

    public function post($path, $handler)
    {
        $this->routes['POST'][$this->normalizePath($path)] = $handler;
    }

    public function dispatch($method, $path)
    {
        $path = $this->normalizePath($path);
        $handler = $this->routes[$method][$path] ?? null;

        if ($handler === null) {
            if ($this->errorHandler) {
                return ($this->errorHandler)(404);
            }

            throw new Exception('Route not found');
        }

        if (is_callable($handler)) {
            $result = $handler();
            return $result === null ? true : $result;
        }

        if (is_array($handler) && count($handler) === 2) {
            [$controllerName, $methodName] = $handler;
            $controllerClass = str_ends_with($controllerName, 'Controller') ? $controllerName : $controllerName . 'Controller';
            $controllerFile = dirname(__DIR__, 1) . '/Controllers/' . $controllerClass . '.php';

            if (!file_exists($controllerFile)) {
                throw new Exception('Controller not found: ' . $controllerClass);
            }

            require_once $controllerFile;
            $controller = new $controllerClass();
            $result = $controller->$methodName();
            return $result === null ? true : $result;
        }

        throw new Exception('Invalid route handler');
    }

    private function normalizePath($path)
    {
        return '/' . trim((string) $path, '/');
    }
}
