import 'package:flutter/material.dart';

class QtyDialog extends StatefulWidget {
  final int initialQty;
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
    qtyController = TextEditingController(text: widget.initialQty.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("modify quantity for ${widget.label}"),
      content: TextField(
        controller: qtyController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(qtyController.text.trim());
            if (qty != null) Navigator.pop(context, qty);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
