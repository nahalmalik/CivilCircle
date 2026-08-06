<?php
class Application
{
    private $router;
    private $request;
    private $response;
    private $session;

    public function __construct()
    {
        Config::loadEnv(dirname(__DIR__, 2) . '/.env');
        $this->request = new Request();
        $this->response = new Response();
        $this->session = new Session();
        $this->router = new Router([$this, 'handleError']);
    }

    public function run()
    {
        try {
            $this->loadRoutes();
            $result = $this->router->dispatch($this->request->getMethod(), $this->request->getPath());

            if ($result === null) {
                $this->response->setStatusCode(204);
            }
        } catch (Throwable $e) {
            $this->handleError($e);
        }
    }

    public function registerRoutes(callable $callback)
    {
        $callback($this->router);
    }

    public function handleError($error)
    {
        if ($error instanceof Throwable) {
            $this->logError($error);
            $this->response->setStatusCode(500);
            echo 'Application Error: ' . $error->getMessage();
            return;
        }

        if ($error === 404) {
            $this->response->setStatusCode(404);
            echo '404 Not Found';
            return;
        }
    }

    public function logError(Throwable $e)
    {
        $logDir = dirname(__DIR__, 2) . '/storage/logs';
        if (!is_dir($logDir)) {
            mkdir($logDir, 0777, true);
        }

        $logFile = $logDir . '/app.log';
        $message = '[' . date('Y-m-d H:i:s') . '] ' . $e->getMessage() . PHP_EOL . $e->getTraceAsString() . PHP_EOL;
        file_put_contents($logFile, $message, FILE_APPEND);
    }

    private function loadRoutes()
    {
        $router = $this->router;
        require dirname(__DIR__, 2) . '/routes/web.php';
    }
}
