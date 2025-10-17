import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class InventarioService {
  final String baseUrl = 'http://localhost/api_inventario/api_inventario.php';

  // LISTAR
  Future<List<Producto>> listarProductos() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Producto.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar productos (${res.statusCode})');
    }
  }

  // OBTENER POR ID
  Future<Producto> obtenerPorId(int id) async {
    final res = await http.get(Uri.parse('$baseUrl?id=$id'));
    if (res.statusCode == 200) {
      return Producto.fromJson(json.decode(res.body));
    } else {
      throw Exception('Producto no encontrado');
    }
  }

  // CREAR
  Future<void> crearProducto(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Error creando producto: ${res.body}');
    }
  }

  // 🔁 ACTUALIZAR (PUT)
  Future<void> actualizarProducto(Producto producto) async {
    final url = Uri.parse('$baseUrl?id=${producto.id}');
    final body = json.encode({
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'codigo_barras': producto.codigoBarras,
      'categoria': producto.categoria,
      'precio': producto.precio,
      'stock': producto.stock,
      'proveedor': producto.proveedor,
      'activo': producto.activo ? 1 : 0,
    });

    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Error al actualizar producto: ${res.body}');
    }
  }

  // 🗑️ ELIMINAR
  Future<void> eliminarProducto(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl?id=$id'));
    if (res.statusCode != 200) {
      throw Exception('Error eliminando producto: ${res.body}');
    }
  }
}
