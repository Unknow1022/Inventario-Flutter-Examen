import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class EditarProductoPage extends StatefulWidget {
  final Producto producto;

  const EditarProductoPage({super.key, required this.producto});

  @override
  State<EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<EditarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _codigoController;
  late TextEditingController _categoriaController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _proveedorController;
  bool _activo = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _codigoController = TextEditingController(text: widget.producto.codigoBarras);
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockController = TextEditingController(text: widget.producto.stock.toString());
    _proveedorController = TextEditingController(text: widget.producto.proveedor);
    _activo = widget.producto.activo;
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    final actualizado = Producto(
      id: widget.producto.id,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      codigoBarras: _codigoController.text,
      categoria: _categoriaController.text,
      precio: double.parse(_precioController.text),
      stock: int.parse(_stockController.text),
      proveedor: _proveedorController.text,
      fechaIngreso: widget.producto.fechaIngreso,
      activo: _activo,
    );

    try {
      await InventarioService().actualizarProducto(actualizado);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _eliminarProducto() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Seguro que deseas eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      try {
        await InventarioService().eliminarProducto(widget.producto.id);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _codigoController, decoration: const InputDecoration(labelText: 'Código de barras'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoría'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _proveedorController, decoration: const InputDecoration(labelText: 'Proveedor'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _enviando ? null : _guardarCambios,
                icon: _enviando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _eliminarProducto,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Eliminar Producto', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Charles Sleiter Valiente Farias - Flutter Inventario App