import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/ItemExcelImporter.dart'; // Your new helper!
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _loading = false;
  String? _error;
  List<Item>? _previewItems;

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
      _error = null;
      _previewItems = null;
    });

    final (items, err) = await ItemExcelImporter.pickAndParseExcel();
    setState(() {
      _loading = false;
      _error = err;
      _previewItems = items;
    });
  }

  void _import() {
    if (_previewItems == null || _previewItems!.isEmpty) return;
    context.read<ItemBloc>().add(ImportItemsEvent(_previewItems!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemImported) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Import successful!")));
          Navigator.pop(context);
        }
        if (state is ItemError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Import failed: ${state.message}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import items from excel'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(17),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Choose Excel File"),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (_previewItems != null) ...[
                      const SizedBox(height: 16),
                      const Text("Preview (first 5 rows):"),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _previewItems!.length > 5
                              ? 5
                              : _previewItems!.length,
                          itemBuilder: (context, index) {
                            final item = _previewItems![index];
                            return ListTile(
                              title: Text(item.label),
                              subtitle: Text(
                                  'Code: ${item.code} | Qty: ${item.quantity}'),
                            );
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Import"),
                        onPressed: _import,
                      )
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}
