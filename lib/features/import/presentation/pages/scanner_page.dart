import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/qteDialog.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final bool useCamera;

  const ScannerPage({super.key, required this.useCamera});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isProcessing = false;
  bool _shouldPop = false;

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
          if (_shouldPop) return; // Prevent further actions after pop

          // Only handle when not already processing
          if (state is ItemFound && !_isProcessing) {
            _isProcessing = true;
            final newQte = await showDialog(
              context: context,
              builder: (ctx) => QtyDialog(
                  initialQty: state.item.quantity, label: state.item.label),
            );
            if (!context.mounted) return;
            if (newQte != null) {
              context.read<ItemBloc>().add(
                    UpdateItemEvent(
                      Item(
                        code: state.item.code,
                        label: state.item.label,
                        description: state.item.description,
                        date: state.item.date,
                        quantity: newQte,
                      ),
                    ),
                  );
              // Do NOT pop here! Wait for ItemUpdated state
            } else {
              _isProcessing =
                  false; // Only allow next scan if dialog was cancelled
            }
          }
          if (state is ItemUpdated) {
            // Now show snackbar and pop the scanner page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Quantity updated!")),
            );
            // Reset Bloc state to prevent dialog from showing again
            context.read<ItemBloc>().add(ResetItemState());
            _shouldPop = true;
            Navigator.pop(context);
          }
          if (state is ItemNotFound && !_isProcessing) {
            _isProcessing = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("item not found : ${state.code}"),
              ),
            );
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
