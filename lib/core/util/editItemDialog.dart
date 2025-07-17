import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';

class EditItemDialog extends StatefulWidget {
  final Item item;
  const EditItemDialog({super.key, required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController labelController;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.item.label);
    // Format the initial quantity to remove unnecessary decimal places
    String initialValue = widget.item.quantity == widget.item.quantity.toInt()
        ? widget.item.quantity.toInt().toString()
        : widget.item.quantity.toString();
    quantityController = TextEditingController(text: initialValue);
  }

  double? _parseQuantity(String text) {
    // Replace comma with dot for decimal parsing
    String normalizedText = text.trim().replaceAll(',', '.');
    return double.tryParse(normalizedText);
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
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                hintText: 'Enter quantity (e.g., 1.5 or 1,5)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Allow digits, commas, and dots
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
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
            final newQty = _parseQuantity(quantityController.text);

            if (newLabel.isNotEmpty && newQty != null && newQty >= 0) {
              // No copyWith, just construct a new Item keeping the code and date
              Navigator.pop(
                context,
                Item(
                  code: widget.item.code,
                  label: newLabel,
                  description:
                      widget.item.description, // Keep existing description
                  date: widget.item.date,
                  quantity: newQty,
                  imageBase64: widget.item.imageBase64, // Keep existing image
                ),
              );
            } else {
              // Show error if invalid input
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Please enter a valid label and positive quantity'),
                  duration: Duration(seconds: 2),
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
