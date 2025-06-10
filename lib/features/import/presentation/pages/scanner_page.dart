import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Item"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) async {
          // Only handle when not already processing
          if (state is ItemFound && !_isProcessing) {
            _isProcessing = true;
            final newQte = await showDialog(
              context: context,
              builder: (ctx) => QtyDialog(
                  initialQty: state.item.quantity, label: state.item.label),
            );
            if (newQte != null) {
              context.read<ItemBloc>().add(UpdateItemEvent(Item(
                    code: state.item.code,
                    label: state.item.label,
                    description: state.item.description,
                    date: state.item.date,
                    quantity: newQte,
                  )));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Quantity updated!")));
              Navigator.pop(context);
            }
            _isProcessing = false; // Allow next scan
          }
          if (state is ItemNotFound && !_isProcessing) {
            _isProcessing = true;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("item not found : ${state.code}")));
            _isProcessing = false;
          }
        },
        builder: (context, state) {
          return MobileScanner(onDetect: (capture) {
            // print('####################SCANNER: onDetect called!');
            // print(
            //     '####################SCANNER: barcodes = ${capture.barcodes}');
            if (capture.barcodes.isEmpty) {
              // print('####################SCANNER: NO BARCODES DETECTED!');
              return;
            }
            final barcode = capture.barcodes.first.rawValue;
            // print('####################SCANNER: barcode value = $barcode');
            if (!_isProcessing && barcode != null) {
              // print(
              //     '####################SCANNER: Sending Bloc event SearchItemByCodeEvent($barcode)');
              context.read<ItemBloc>().add(SearchItemByCodeEvent(barcode));
            }
          });
        },
      ),
    );
  }
}

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
