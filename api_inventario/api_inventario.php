<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require 'conexion.php';

$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? intval($_GET['id']) : null;
$input = json_decode(file_get_contents('php://input'), true);

// READ
if ($method === 'GET') {
    if ($id) {
        $stmt = $pdo->prepare('SELECT * FROM productos WHERE id = ?');
        $stmt->execute([$id]);
        $prod = $stmt->fetch();
        if ($prod) echo json_encode($prod);
        else { http_response_code(404); echo json_encode(['error' => 'Producto no encontrado']); }
    } else {
        $stmt = $pdo->query('SELECT * FROM productos ORDER BY id DESC');
        $all = $stmt->fetchAll();
        echo json_encode($all);
    }
    exit;
}

// CREATE
if ($method === 'POST') {
    $nombre = trim($input['nombre'] ?? '');
    $descripcion = trim($input['descripcion'] ?? '');
    $codigo_barras = trim($input['codigo_barras'] ?? '');
    $categoria = trim($input['categoria'] ?? '');
    $precio = $input['precio'] ?? null;
    $stock = $input['stock'] ?? 0;
    $proveedor = trim($input['proveedor'] ?? '');
    $activo = isset($input['activo']) ? (bool)$input['activo'] : true;

    // Validaciones
    if (!$nombre || !$descripcion || !$codigo_barras || !$categoria || $precio === null || !$proveedor) {
        http_response_code(400);
        echo json_encode(['error' => 'Faltan campos obligatorios']);
        exit;
    }
    if (!is_numeric($precio) || floatval($precio) <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Precio inválido, debe ser > 0']);
        exit;
    }

    // ISBN único -> código de barras único
    $stmt = $pdo->prepare('SELECT id FROM productos WHERE codigo_barras = ?');
    $stmt->execute([$codigo_barras]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Código de barras ya existe']);
        exit;
    }

    $stmt = $pdo->prepare('INSERT INTO productos (nombre, descripcion, codigo_barras, categoria, precio, stock, proveedor, activo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([$nombre, $descripcion, $codigo_barras, $categoria, floatval($precio), intval($stock), $proveedor, $activo ? 1 : 0]);
    http_response_code(201);
    echo json_encode(['message' => 'Producto creado', 'id' => $pdo->lastInsertId()]);
    exit;
}

// UPDATE
if ($method === 'PUT') {
    if (!$id) { http_response_code(400); echo json_encode(['error' => 'ID requerido para actualizar']); exit; }

    $nombre = trim($input['nombre'] ?? '');
    $descripcion = trim($input['descripcion'] ?? '');
    $codigo_barras = trim($input['codigo_barras'] ?? '');
    $categoria = trim($input['categoria'] ?? '');
    $precio = $input['precio'] ?? null;
    $stock = $input['stock'] ?? 0;
    $proveedor = trim($input['proveedor'] ?? '');
    $activo = isset($input['activo']) ? (bool)$input['activo'] : true;

    if (!$nombre || !$descripcion || !$codigo_barras || !$categoria || $precio === null || !$proveedor) {
        http_response_code(400);
        echo json_encode(['error' => 'Faltan campos obligatorios']);
        exit;
    }
    if (!is_numeric($precio) || floatval($precio) <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Precio inválido, debe ser > 0']);
        exit;
    }

    // Verificar unicidad código_barras (excluyendo este id)
    $stmt = $pdo->prepare('SELECT id FROM productos WHERE codigo_barras = ? AND id <> ?');
    $stmt->execute([$codigo_barras, $id]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Código de barras ya registrado por otro producto']);
        exit;
    }

    $stmt = $pdo->prepare('UPDATE productos SET nombre=?, descripcion=?, codigo_barras=?, categoria=?, precio=?, stock=?, proveedor=?, activo=? WHERE id=?');
    $stmt->execute([$nombre, $descripcion, $codigo_barras, $categoria, floatval($precio), intval($stock), $proveedor, $activo ? 1 : 0, $id]);
    echo json_encode(['message' => 'Producto actualizado']);
    exit;
}

// DELETE
if ($method === 'DELETE') {
    if (!$id) { http_response_code(400); echo json_encode(['error' => 'ID requerido para eliminar']); exit; }

    $stmt = $pdo->prepare('DELETE FROM productos WHERE id = ?');
    $stmt->execute([$id]);
    echo json_encode(['message' => 'Producto eliminado']);
    exit;
}

http_response_code(405);
echo json_encode(['error' => 'Método no soportado']);
