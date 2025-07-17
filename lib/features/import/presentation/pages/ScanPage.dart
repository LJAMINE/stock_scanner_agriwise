import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          final newQty = await showDialog<double>(
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
            SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)?.itemNotFound ?? 'Item not found:'} ${state.code}!')),
          );
          _pendingScanCode = null;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.scanItems ?? "Scan Items",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF356033),
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF356033),
                  Color(0xFF2D5129),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 8), // Reduced from 16 to 8
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF356033).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: "scan_page_fab",
            backgroundColor: Color(0xFF356033),
            foregroundColor: Colors.white,
            onPressed: () {
              setState(() {
                _scanning = !_scanning;
              });
            },
            icon: Icon(
              _scanning ? Icons.close : Icons.qr_code_scanner,
              size: 24,
            ),
            label: Text(
              _scanning
                  ? (AppLocalizations.of(context)?.stopScan ?? 'Stop Scan')
                  : (AppLocalizations.of(context)?.startScan ?? 'Start Scan'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF356033).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              if (_scanning)
                Container(
                  margin: EdgeInsets.fromLTRB(
                      16, 8, 16, 8), // Reduced top and bottom margin
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height:
                          250, // Reduced from 300 to 250 to prevent overflow
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
                  ),
                ),
              if (_scanning)
                Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF356033).withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: _scanning
                          ? 60
                          : 50), // Further reduced padding to account for save button
                  child: scannedItems.isEmpty
                      ? SizedBox
                          .shrink() // Just empty space when no items scanned
                      : Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16,
                              8), // Reduced bottom margin from 16 to 8
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF356033).withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Table
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            Color(0xFF356033).withOpacity(0.2),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        // Table Header
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF356033)
                                                .withOpacity(0.05),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                          ?.code ??
                                                      'Code',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF356033),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                          ?.label ??
                                                      'Product Name',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF356033),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                          ?.quantity ??
                                                      'Qty',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF356033),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Table Rows
                                        ...scannedItems
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          final isEven = index % 2 == 0;

                                          return Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isEven
                                                  ? Colors.white
                                                  : Color(0xFF356033)
                                                      .withOpacity(0.02),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFF356033)
                                                      .withOpacity(0.1),
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF356033)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      item.code,
                                                      style: TextStyle(
                                                        fontFamily: 'monospace',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF356033),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    item.label,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  flex: 2,
                                                  child: Center(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF356033),
                                                            Color(0xFF2D5129),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        item.quantity ==
                                                                item.quantity
                                                                    .toInt()
                                                            ? '${item.quantity.toInt()}'
                                                            : '${item.quantity}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Save Button Section
                              if (scannedItems.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 8), // Reduced from 24 to 8
                                  padding: EdgeInsets.all(
                                      16), // Reduced from 20 to 16
                                  decoration: BoxDecoration(
                                    color: Color(0xFF356033).withOpacity(0.05),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF356033),
                                              Color(0xFF2D5129),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF356033)
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.archive_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          label: Text(
                                            AppLocalizations.of(context)
                                                    ?.saveBatch ??
                                                'Save Batch',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () {
                                            print(
                                                'DEBUG: Save button pressed with ${scannedItems.length} items');
                                            // Save scannedItems to archive
                                            context
                                                .read<ItemBloc>()
                                                .add(SaveBatchToArchiveEvent(
                                                  items: List<Item>.from(
                                                      scannedItems),
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
                                                content: Text(AppLocalizations
                                                            .of(context)
                                                        ?.batchSavedSuccessfully ??
                                                    'Batch saved successfully!'),
                                                backgroundColor:
                                                    Color(0xFF356033),
                                                duration: Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Add bottom padding to avoid FAB overlap
                              SizedBox(
                                  height: 8), // Further reduced from 16 to 8
                            ],
                          ),
                        ),
                ), // Close Padding widget
              ),
            ],
          ),
        ),
      ),
    );
  }
}
