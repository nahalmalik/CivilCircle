<?php
class Config
{
    private static $env = [];
    private static $loaded = false;

    public static function loadEnv($path)
    {
        if (self::$loaded) {
            return;
        }

        if (!file_exists($path)) {
            throw new RuntimeException('Environment file not found: ' . $path);
        }

        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            if (strpos(trim($line), '#') === 0) {
                continue;
            }

            [$name, $value] = array_pad(explode('=', $line, 2), 2, '');
            $name = trim($name);
            $value = trim($value);
            if ($name === '') {
                continue;
            }

            self::$env[$name] = self::parseValue($value);
        }

        self::$loaded = true;
    }

    public static function get($key, $default = null)
    {
        if (!self::$loaded) {
            self::loadEnv(dirname(__DIR__, 2) . '/.env');
        }

        return self::$env[$key] ?? $default;
    }

    public static function all()
    {
        if (!self::$loaded) {
            self::loadEnv(dirname(__DIR__, 2) . '/.env');
        }

        return self::$env;
    }

    private static function parseValue($value)
    {
        if ($value === 'true') {
            return true;
        }
        if ($value === 'false') {
            return false;
        }
        if ($value === 'null') {
            return null;
        }

        return $value;
    }
}
