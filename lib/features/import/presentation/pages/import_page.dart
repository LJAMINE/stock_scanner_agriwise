import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/ItemExcelImporter.dart';
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
  List<Item> _previewItems = [];

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
      _error = null;
      _previewItems = [];
    });

    final (items, err) = await ItemExcelImporter.pickAndParseExcel();
    setState(() {
      _loading = false;
      _error = err;
      _previewItems = items ?? [];
    });
  }

  void _import() {
    if (_previewItems.isEmpty) return;
    context.read<ItemBloc>().add(ImportItemsEvent(_previewItems));
  }

  void _showManualAddDialog({int? editIndex, Item? editItem}) {
    final codeController = TextEditingController(text: editItem?.code ?? "");
    final labelController = TextEditingController(text: editItem?.label ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editItem == null ? "Add Item manually" : "Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Code"),
              enabled: editItem == null, // Can't edit code on edit
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: "Label"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              final label = labelController.text.trim();

              if (code.isNotEmpty && label.isNotEmpty) {
                setState(() {
                  if (editItem != null && editIndex != null) {
                    // Update item
                    _previewItems[editIndex] = Item(
                      code: editItem.code,
                      label: label,
                      description: editItem.description,
                      date: editItem.date,
                      quantity: editItem.quantity,
                    );
                  } else {
                    // Add new
                    _previewItems.add(Item(
                        code: code,
                        label: label,
                        description: "",
                        date: "",
                        quantity: 0));
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text(editItem == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
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
                    ElevatedButton.icon(
                      onPressed: () => _showManualAddDialog(),
                      label: const Text("Add manually"),
                      icon: const Icon(Icons.add),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (_previewItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text("Preview (first 5 rows):"),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _previewItems.length > 5
                              ? 5
                              : _previewItems.length,
                          itemBuilder: (context, index) {
                            final item = _previewItems[index];
                            return ListTile(
                              title: Text(item.label),
                              subtitle: Text(
                                  'Code: ${item.code} | Qty: ${item.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _showManualAddDialog(
                                        editIndex: index, editItem: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _previewItems.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
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
