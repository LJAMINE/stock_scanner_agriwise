import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/qteDialog.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<Item> scannedItems = [];
  String? _pendingScanCode;
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) async {
        if (state is ItemFound && _pendingScanCode != null) {
          final item = state.item;
          final newQty = await showDialog<int>(
            context: context,
            builder: (ctx) => QtyDialog(
              initialQty: item.quantity,
              label: item.label,
            ),
          );
          // Ensure dialog is closed before continuing
          // if (Navigator.of(context).canPop()) {
          //   Navigator.of(context).pop();
          // }
          if (newQty != null) {
            setState(() {
              final idx = scannedItems.indexWhere((i) => i.code == item.code);
              final updated = Item(
                code: item.code,
                label: item.label,
                description: item.description,
                date: item.date,
                quantity: newQty,
                imageBase64: item.imageBase64,
              );
              if (idx >= 0) {
                scannedItems[idx] = updated;
              } else {
                scannedItems.add(updated);
              }
            });
          }
          _pendingScanCode = null;
        } else if (state is ItemNotFound && _pendingScanCode != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item not found: ${state.code}!')),
          );
          _pendingScanCode = null;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Scan Page"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            if (scannedItems.isNotEmpty)
              IconButton(
                icon: Icon(Icons.save),
                tooltip: 'Save batch to archive',
                onPressed: () {
                  // Save scannedItems to archive (dispatch Bloc event or call your archive logic)
                  context.read<ItemBloc>().add(SaveBatchToArchiveEvent(
                        items: List<Item>.from(scannedItems),
                        date: DateTime.now(),
                      ));
                  setState(() {
                    scannedItems.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Batch saved to archive!')),
                  );
                },
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _scanning = !_scanning;
            });
          },
          child: Icon(_scanning ? Icons.close : Icons.qr_code_scanner),
        ),
        body: Column(
          children: [
            if (_scanning)
              Expanded(
                flex: 2,
                child: MobileScanner(
                  onDetect: (capture) {
                    if (capture.barcodes.isEmpty) return;
                    final barcode = capture.barcodes.first.rawValue;
                    if (_pendingScanCode == null && barcode != null) {
                      _pendingScanCode = barcode;
                      context
                          .read<ItemBloc>()
                          .add(SearchItemByCodeEvent(barcode));
                    }
                  },
                ),
              ),
            if (_scanning) Divider(),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: scannedItems.length,
                itemBuilder: (context, index) {
                  final item = scannedItems[index];
                  return ListTile(
                    title: Text(item.label),
                    subtitle:
                        Text('Code: ${item.code} | Qty: ${item.quantity}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
