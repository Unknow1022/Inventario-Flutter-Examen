class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final String codigoBarras;
  final String categoria;
  final double precio;
  final int stock;
  final String proveedor;
  final String fechaIngreso;
  final bool activo;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigoBarras,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.proveedor,
    required this.fechaIngreso,
    required this.activo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      codigoBarras: json['codigo_barras'] ?? '',
      categoria: json['categoria'] ?? '',
      precio: double.parse(json['precio'].toString()),
      stock: int.parse(json['stock'].toString()),
      proveedor: json['proveedor'] ?? '',
      fechaIngreso: json['fecha_ingreso'] ?? '',
      activo: (json['activo'] == 1 || json['activo'] == '1' || json['activo'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_barras': codigoBarras,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'proveedor': proveedor,
      'activo': activo ? 1 : 0,
    };
  }
}
