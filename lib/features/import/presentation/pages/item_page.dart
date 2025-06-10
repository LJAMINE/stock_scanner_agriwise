import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item> _items = [];

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
            onPressed: () => Navigator.pushNamed(context, '/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              context.read<ItemBloc>().add(ExportItemsEvent(_items));
            },
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ItemUpdated) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Item updated!")));
          }
          if (state is ItemDeleted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Item deleted!")));
          }
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'File saved in Download folder:\n${state.filePath}')),
            );
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
            _items = state.items;
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
