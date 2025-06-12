import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/scan_mode_prefs.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/scanner_page.dart';
import 'package:open_filex/open_filex.dart';
// Add this import at the top with the others:
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/src/x_file.dart';
import 'package:path_provider/path_provider.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item> _items = []; // Only for export, do not use for UI display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.pushNamed(context, '/import'),
          ),
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: () => startScan(context),

            // onPressed: () => Navigator.pushNamed(context, '/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Get the latest items from Bloc state for export
              final state = context.read<ItemBloc>().state;
              if (state is ItemsLoaded) {
                _items = state.items;
                context.read<ItemBloc>().add(ExportItemsEvent(_items));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No items to export.")),
                );
              }
            },
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Change Scan Mode',
            onPressed: () async {
              await clearScanMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Scan mode preference cleared! Next scan will ask again.')),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          // if (state is ItemUpdated) {
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(const SnackBar(content: Text("Item updated!")));
          // }

          if (state is ItemUpdated) {
            // After an item is updated, reload all items
            context.read<ItemBloc>().add(GetAllItemsEvent());
            // Optionally show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item updated!')),
            );
          }
          if (state is ItemDeleted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Item deleted!")));
          }
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved at:\n${state.filePath}'),
                action: SnackBarAction(
                  label: 'Actions',
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.open_in_new),
                              title: const Text('Open'),
                              onTap: () {
                                OpenFilex.open(state.filePath);
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.download),
                              title: const Text('Save to Downloads'),
                              onTap: () async {
                                try {
                                  String? pickedDir = await FilePicker.platform
                                      .getDirectoryPath(
                                    dialogTitle:
                                        'Select folder to save Excel file',
                                  );
                                  if (pickedDir != null) {
                                    final fileName =
                                        state.filePath.split('/').last;
                                    final destPath = '$pickedDir/$fileName';
                                    final sourceFile = File(state.filePath);
                                    final bytes =
                                        await sourceFile.readAsBytes();
                                    final destFile = File(destPath);
                                    await destFile.writeAsBytes(bytes);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('File saved to: $destPath')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'File save cancelled or failed.')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Save failed: $e')),
                                  );
                                }
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Share'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                // Use share_plus to share the file
                                try {
                                  // ignore: use_build_context_synchronously
                                  await Share.shareXFiles(
                                      [XFile(state.filePath)],
                                      text: 'Here is the exported Excel file.');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Share failed: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
            context.read<ItemBloc>().add(GetAllItemsEvent());
          }

          if (state is ExportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Export failed: ${state.message}")));
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemsLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text("No items found."));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.label),
                  subtitle: Text('Code: ${item.code} | Qty: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updated = await showDialog<Item>(
                            context: context,
                            builder: (_) => EditItemDialog(item: item),
                          );
                          if (updated != null) {
                            context
                                .read<ItemBloc>()
                                .add(UpdateItemEvent(updated));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Item"),
                              content: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<ItemBloc>()
                                        .add(DeleteItemEvent(item.code));
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ItemError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

Future<void> startScan(BuildContext context) async {
  bool? useCamera = await loadScanMode();
  if (useCamera == null) {
    useCamera = await showScanModeDialog(context);
    if (useCamera != null) {
      await saveScanMode(useCamera);
    } else {
      // User cancelled dialog
      return;
    }
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ScannerPage(useCamera: useCamera!),
    ),
  );
}

class EditItemDialog extends StatefulWidget {
  final Item item;
  const EditItemDialog({super.key, required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController labelController;
  late TextEditingController descriptionController;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.item.label);
    descriptionController =
        TextEditingController(text: widget.item.description);
    quantityController =
        TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Item"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Code"),
              controller: TextEditingController(text: widget.item.code),
              enabled: false,
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: "Label"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final newLabel = labelController.text.trim();
            final newDesc = descriptionController.text.trim();
            final newQty = int.tryParse(quantityController.text.trim()) ?? 0;

            if (newLabel.isNotEmpty) {
              // No copyWith, just construct a new Item keeping the code and date
              Navigator.pop(
                context,
                Item(
                  code: widget.item.code,
                  label: newLabel,
                  description: newDesc,
                  date: widget.item.date,
                  quantity: newQty,
                ),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
