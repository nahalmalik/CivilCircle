<?php
function url($path = '')
{
    $base = rtrim((string) Config::get('APP_URL', ''), '/');
    if ($base === '') {
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https://' : 'http://';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $base = $scheme . $host;
    }

    $path = ltrim($path, '/');
    return $base . ($path ? '/' . $path : '');
}

function asset($path)
{
    return url('public/assets/' . ltrim($path, '/'));
}

function e($value)
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function sanitizeInput($value)
{
    if (is_array($value)) {
        return array_map('sanitizeInput', $value);
    }

    return trim(strip_tags((string) $value));
}

function isValidEmail($email)
{
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function validateRequired(array $data, array $fields)
{
    $errors = [];
    foreach ($fields as $field) {
        if (!isset($data[$field]) || trim((string) $data[$field]) === '') {
            $errors[] = $field;
        }
    }

    return $errors;
}
