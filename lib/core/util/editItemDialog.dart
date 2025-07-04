import 'package:flutter/material.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';

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
