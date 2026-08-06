<?php
class Model
{
    protected $db;
    protected $table;

    public function __construct($table = null)
    {
        $this->db = Database::getInstance()->getConnection();
        $this->table = $table;
    }

    public function find($id)
    {
        $stmt = $this->db->prepare('SELECT * FROM ' . $this->table . ' WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }

    public function findAll($conditions = [], $orderBy = null, $limit = null)
    {
        $sql = 'SELECT * FROM ' . $this->table;
        $params = [];

        if (!empty($conditions)) {
            $where = [];
            foreach ($conditions as $field => $value) {
                $where[] = $field . ' = :' . $field;
                $params[':' . $field] = $value;
            }
            $sql .= ' WHERE ' . implode(' AND ', $where);
        }

        if ($orderBy) {
            $sql .= ' ORDER BY ' . $orderBy;
        }

        if ($limit) {
            $sql .= ' LIMIT ' . (int) $limit;
        }

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public function create(array $data)
    {
        $fields = array_keys($data);
        $placeholders = array_map(function ($field) {
            return ':' . $field;
        }, $fields);

        $sql = 'INSERT INTO ' . $this->table . ' (' . implode(', ', $fields) . ') VALUES (' . implode(', ', $placeholders) . ')';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        return $this->db->lastInsertId();
    }

    public function update($id, array $data)
    {
        $fields = [];
        foreach ($data as $field => $value) {
            $fields[] = $field . ' = :' . $field;
        }

        $sql = 'UPDATE ' . $this->table . ' SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $this->db->prepare($sql);
        $data[':id'] = $id;
        return $stmt->execute($data);
    }

    public function delete($id)
    {
        $stmt = $this->db->prepare('DELETE FROM ' . $this->table . ' WHERE id = :id');
        return $stmt->execute([':id' => $id]);
    }

    public function query($sql, array $params = [])
    {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }
}
