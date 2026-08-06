<?php
require dirname(__DIR__) . '/app/Config/Config.php';
require dirname(__DIR__) . '/app/Core/Database.php';
require dirname(__DIR__) . '/app/Core/Request.php';
require dirname(__DIR__) . '/app/Core/Response.php';
require dirname(__DIR__) . '/app/Core/Session.php';
require dirname(__DIR__) . '/app/Core/Router.php';
require dirname(__DIR__) . '/app/Core/Controller.php';
require dirname(__DIR__) . '/app/Core/Model.php';
require dirname(__DIR__) . '/app/Core/Application.php';
require dirname(__DIR__) . '/app/Helpers/helpers.php';
require dirname(__DIR__) . '/app/Middleware/CsrfMiddleware.php';
require dirname(__DIR__) . '/app/Controllers/BaseController.php';

$app = new Application();
$app->run();
