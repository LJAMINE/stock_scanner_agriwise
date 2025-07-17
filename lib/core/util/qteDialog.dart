import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QtyDialog extends StatefulWidget {
  final double initialQty;
  final String label;
  const QtyDialog({super.key, required this.initialQty, required this.label});

  @override
  State<QtyDialog> createState() => _QtyDialogState();
}

class _QtyDialogState extends State<QtyDialog> {
  late TextEditingController qtyController;

  @override
  void initState() {
    super.initState();
    // Format the initial quantity to remove unnecessary decimal places
    String initialValue = widget.initialQty == widget.initialQty.toInt()
        ? widget.initialQty.toInt().toString()
        : widget.initialQty.toString();
    qtyController = TextEditingController(text: initialValue);
  }

  double? _parseQuantity(String text) {
    // Replace comma with dot for decimal parsing
    String normalizedText = text.trim().replaceAll(',', '.');
    return double.tryParse(normalizedText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("modify quantity for ${widget.label}"),
      content: TextField(
        controller: qtyController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Allow digits, commas, and dots
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        decoration: const InputDecoration(
          labelText: 'Quantity',
          hintText: 'Enter quantity (e.g., 1.5 or 1,5)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = _parseQuantity(qtyController.text);
            if (qty != null && qty >= 0) {
              Navigator.pop(context, qty);
            } else {
              // Show error if invalid input
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid positive number'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
