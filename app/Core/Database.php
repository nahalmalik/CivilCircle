<?php
class Database
{
    private static $instance = null;
    private $pdo;

    private function __construct()
    {
        $host = Config::get('DB_HOST', '127.0.0.1');
        $dbName = Config::get('DB_NAME', 'civilcircle');
        $username = Config::get('DB_USERNAME', 'root');
        $password = Config::get('DB_PASSWORD', '');

        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $host, $dbName);

        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4'
        ];

        try {
            $this->pdo = new PDO($dsn, $username, $password, $options);
        } catch (PDOException $e) {
            throw new Exception('Database connection failed: ' . $e->getMessage());
        }
    }

    public static function getInstance()
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }

        return self::$instance;
    }

    public function getConnection()
    {
        return $this->pdo;
    }
}
