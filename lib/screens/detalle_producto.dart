import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import 'editar_producto.dart';

class DetalleProductoPage extends StatelessWidget {
  final Producto producto;
  const DetalleProductoPage({super.key, required this.producto});

  Future<void> _confirmarEliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      try {
        await InventarioService().eliminarProducto(producto.id);
        if (context.mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool bajoStock = producto.stock <= 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditarProductoPage(producto: producto)),
              );
              if (context.mounted && res == true) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(producto.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Proveedor: ${producto.proveedor}'),
            Text('Categoría: ${producto.categoria}'),
            Text('Código: ${producto.codigoBarras}'),
            const SizedBox(height: 8),
            Text('Precio: \$${producto.precio.toStringAsFixed(2)}'),
            Text(
              'Stock: ${producto.stock}${bajoStock ? " (Bajo stock)" : ""}',
              style: TextStyle(color: bajoStock ? Colors.red : Colors.black),
            ),
            const SizedBox(height: 8),
            Text('Descripción:\n${producto.descripcion}'),
            const SizedBox(height: 12),
            Text('Fecha ingreso: ${producto.fechaIngreso}'),
            const SizedBox(height: 12),
            Text('Activo: ${producto.activo ? "Sí" : "No"}'),
          ],
        ),
      ),
    );
  }
}

// Charles Sleiter Valiente Farias - Flutter Inventario App
