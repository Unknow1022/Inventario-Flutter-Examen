import 'package:flutter/material.dart';
import '../services/inventario_service.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _codigo = TextEditingController();
  final _categoria = TextEditingController();
  final _precio = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _proveedor = TextEditingController();
  bool _activo = true;
  bool _sending = false;
  final InventarioService service = InventarioService();

  Future<void> guardar() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _sending = true);
  try {
    await service.crearProducto({
      'nombre': _nombre.text,
      'descripcion': _descripcion.text,
      'codigo_barras': _codigo.text,
      'categoria': _categoria.text,
      'precio': double.parse(_precio.text),
      'stock': int.parse(_stock.text),
      'proveedor': _proveedor.text,
      'activo': _activo ? 1 : 0,
    });

    if (!mounted) return;
     Navigator.pop(context, true);
  } catch (e) {
     if (!mounted) return;
       ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    if (mounted) setState(() => _sending = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _descripcion, decoration: const InputDecoration(labelText: 'Descripción'), validator: (v) => v!.isEmpty ? 'Requerido' : null, maxLines: 2),
              TextFormField(controller: _codigo, decoration: const InputDecoration(labelText: 'Código de Barras'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _categoria, decoration: const InputDecoration(labelText: 'Categoría'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(
                controller: _precio,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Precio inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              TextFormField(controller: _proveedor, decoration: const InputDecoration(labelText: 'Proveedor'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              SwitchListTile(title: const Text('Activo'), value: _activo, onChanged: (v) => setState(() => _activo = v)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _sending ? null : guardar,
                child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Charles Sleiter Valiente Farias - Flutter Inventario App