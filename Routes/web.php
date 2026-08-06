<?php
$router->get('/', function () {
    echo 'CivilCircle core framework is running.';
});

$router->get('/test', function () {
    $status = [
        'status' => 'ok',
        'app' => Config::get('APP_NAME'),
        'database' => 'unavailable',
        'routing' => 'working'
    ];

    try {
        $db = Database::getInstance()->getConnection();
        $stmt = $db->query('SELECT 1');
        $result = $stmt->fetchColumn();
        $status['database'] = $result == 1 ? 'connected' : 'failed';
    } catch (Throwable $e) {
        $status['database'] = 'unavailable';
        $status['database_error'] = $e->getMessage();
    }

    echo json_encode($status);
});

$router->get('/login', ['AuthController', 'login']);
$router->post('/login', ['AuthController', 'login']);
$router->get('/register', ['AuthController', 'register']);
$router->post('/register', ['AuthController', 'register']);
$router->get('/logout', ['AuthController', 'logout']);
$router->get('/forgot-password', ['AuthController', 'forgotPassword']);
$router->post('/forgot-password', ['AuthController', 'forgotPassword']);
$router->get('/reset-password', ['AuthController', 'resetPassword']);
$router->post('/reset-password', ['AuthController', 'resetPassword']);
$router->get('/verify-email', ['AuthController', 'verifyEmail']);
$router->get('/dashboard', ['DashboardController', 'index']);
$router->get('/profile/settings', ['ProfileController', 'settings']);
$router->post('/profile/settings', ['ProfileController', 'settings']);
