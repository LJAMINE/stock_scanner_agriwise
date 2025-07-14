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
          title: const Text(
            "Scan Items",
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
        floatingActionButton: Container(
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
              _scanning ? 'Stop Scan' : 'Start Scan',
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
                  margin: EdgeInsets.all(16),
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
                      height: 300,
                      child: Stack(
                        children: [
                          MobileScanner(
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
                          // Scan overlay
                          Center(
                            child: Container(
                              width: 250,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF356033),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  // Corner decorations
                                  Positioned(
                                    top: -1,
                                    left: -1,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF356033),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -1,
                                    right: -1,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF356033),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -1,
                                    left: -1,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF356033),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -1,
                                    right: -1,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF356033),
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Scan instruction
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF356033).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Position barcode within the frame',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                child: scannedItems.isEmpty
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color(0xFF356033).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 80,
                                  color: Color(0xFF356033),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Ready to Scan',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF356033),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Tap the scan button to start adding items to your batch',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 32),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF356033).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Color(0xFF356033).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: Color(0xFF356033),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Scanned items will appear here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF356033),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.all(16),
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
                            // Header
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF356033),
                                    Color(0xFF2D5129),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Scanned Items',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${scannedItems.length} items in batch',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      '${scannedItems.length}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF356033),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Table
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFF356033).withOpacity(0.2),
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
                                            topLeft: Radius.circular(11),
                                            topRight: Radius.circular(11),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'Code',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF356033),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Product Name',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF356033),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
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
                                                flex: 2,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
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
                                                      color: Color(0xFF356033),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  item.label,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                flex: 1,
                                                child: Center(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF356033),
                                                          Color(0xFF2D5129),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
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
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF356033).withOpacity(0.05),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF356033)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                            color: Color(0xFF356033),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Ready to save ${scannedItems.length} items to your archive',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF356033),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
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
                                        borderRadius: BorderRadius.circular(16),
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
                                          'Save Batch to Archive',
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
                                              vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
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
                                              content: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Success!',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Batch saved to archive and items updated',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              backgroundColor:
                                                  Color(0xFF356033),
                                              duration: Duration(seconds: 4),
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
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
