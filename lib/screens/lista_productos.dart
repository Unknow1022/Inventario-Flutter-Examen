import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';
import 'agregar_producto.dart';
import 'detalle_producto.dart';

class ListaProductosPage extends StatefulWidget {
  const ListaProductosPage({super.key});

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  final InventarioService service = InventarioService();
  late Future<List<Producto>> futuros;

  @override
  void initState() {
    super.initState();
    futuros = service.listarProductos();
  }

  Future<void> refresh() async {
    setState(() {
      futuros = service.listarProductos();
    });
    await futuros;
  }

  Future<void> _confirmEliminar(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
   if (ok == true) {
     await service.eliminarProducto(id);
   if (!mounted) return;
     await refresh();
   if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado')),
  );
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario - Productos'),
        actions: [
          IconButton(onPressed: refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Producto>>(
        future: futuros,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No hay productos'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final p = items[i];
              final bajoStock = p.stock <= 5;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(p.nombre),
                  subtitle: Text('${p.categoria} • ${p.proveedor}\nCódigo: ${p.codigoBarras}'),
                  isThreeLine: true,
                  leading: Icon(Icons.inventory, color: p.activo ? Colors.lightBlueAccent : Colors.black),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\$${p.precio.toStringAsFixed(2)}'),
                      if (bajoStock)
                        Text('Stock: ${p.stock}', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetalleProductoPage(producto: p)),
                    );
                    if (context.mounted && res == true) refresh();
                  },
                  onLongPress: () => _confirmEliminar(p.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        onPressed: () async {
          final r = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarProductoPage()),
          );
          if (context.mounted && r == true) refresh();
        },
      ),
    );
  }
}


// Charles Sleiter Valiente Farias - Flutter Inventario App