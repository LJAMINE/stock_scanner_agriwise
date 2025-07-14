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
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "scan_page_fab",
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
              child: scannedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No items scanned yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start scanning to add items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Scanned Items (${scannedItems.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 20,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.blue[50],
                                ),
                                border: TableBorder.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Label',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    numeric: true,
                                  ),
                                ],
                                rows: scannedItems.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.code,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            item.label,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Save Button Section
                        if (scannedItems.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ready to save ${scannedItems.length} items to archive',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.archive,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Save Batch to Archive',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    onPressed: () {
                                      // Save scannedItems to archive
                                      context
                                          .read<ItemBloc>()
                                          .add(SaveBatchToArchiveEvent(
                                            items:
                                                List<Item>.from(scannedItems),
                                            date: DateTime.now(),
                                          ));

                                      // Update each item in the main database
                                      for (final item in scannedItems) {
                                        context
                                            .read<ItemBloc>()
                                            .add(UpdateItemEvent(item));
                                      }

                                      setState(() {
                                        scannedItems.clear();
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                  'Batch saved to archive and items updated!'),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
