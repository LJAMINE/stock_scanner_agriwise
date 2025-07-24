// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_stock_scanner/core/util/qteDialog.dart';
// import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
// import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
// import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
// import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class ScanPage extends StatefulWidget {
//   const ScanPage({super.key});

//   @override
//   State<ScanPage> createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
//   List<Item> scannedItems = [];
//   String? _pendingScanCode;
//   bool _scanning = false;
//   MobileScannerController? scannerController;

//   @override
//   void initState() {
//     super.initState();
//     scannerController = MobileScannerController();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     scannerController?.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       if (_scanning) {
//         _stopScanning();
//       }
//     }
//   }

//   void _stopScanning() {
//     setState(() {
//       _scanning = false;
//     });
//     scannerController?.stop();
//   }

//   void _startScanning() {
//     setState(() {
//       _scanning = true;
//     });
//     scannerController?.start();
//   }

//   void _saveItems() async {
//     // Update each item in the main database first
//     for (final item in scannedItems) {
//       context.read<ItemBloc>().add(UpdateItemEvent(item));
//     }

//     // Save scannedItems to archive
//     context.read<ItemBloc>().add(SaveBatchToArchiveEvent(
//           items: List<Item>.from(scannedItems),
//           date: DateTime.now(),
//         ));

//     // Clear scanned items
//     setState(() {
//       scannedItems.clear();
//     });

//     // Stop scanning
//     _stopScanning();

//     // Reload all items to refresh the ItemPage
//     context.read<ItemBloc>().add(GetAllItemsEvent());

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(AppLocalizations.of(context)?.batchSavedSuccessfully ??
//             'Batch saved successfully!'),
//         backgroundColor: Color(0xFF356033),
//         duration: Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_scanning) {
//           _stopScanning();
//         }
//         return true;
//       },
//       child: BlocListener<ItemBloc, ItemState>(
//         listener: (context, state) async {
//           if (state is ItemFound && _pendingScanCode != null) {
//             final item = state.item;
//             final newQty = await showDialog<double>(
//               context: context,
//               builder: (ctx) => QtyDialog(
//                 initialQty: item.quantity,
//                 label: item.label,
//               ),
//             );

//             if (newQty != null) {
//               setState(() {
//                 final idx = scannedItems.indexWhere((i) => i.code == item.code);
//                 final updated = Item(
//                   code: item.code,
//                   label: item.label,
//                   description: item.description,
//                   date: item.date,
//                   quantity: newQty,
//                   imageBase64: item.imageBase64,
//                 );
//                 if (idx >= 0) {
//                   scannedItems[idx] = updated;
//                 } else {
//                   scannedItems.add(updated);
//                 }
//               });
//             }
//             _pendingScanCode = null;
//           } else if (state is ItemNotFound && _pendingScanCode != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     '${AppLocalizations.of(context)?.itemNotFound ?? 'Item not found:'} ${state.code}!'),
//               ),
//             );
//             _pendingScanCode = null;
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text(
//               AppLocalizations.of(context)?.scanItems ?? "Scan Items",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: Color(0xFF356033),
//             foregroundColor: Colors.white,
//             elevation: 0,
//             flexibleSpace: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF356033),
//                     Color(0xFF2D5129),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               // Start/Stop Scan Button
//               Container(
//                 margin: EdgeInsets.only(right: 16),
//                 child: IconButton(
//                   onPressed: () {
//                     if (_scanning) {
//                       _stopScanning();
//                     } else {
//                       _startScanning();
//                     }
//                   },
//                   icon: Icon(
//                     _scanning ? Icons.stop_circle : Icons.play_circle_filled,
//                     size: 28,
//                   ),
//                   tooltip: _scanning
//                       ? (AppLocalizations.of(context)?.stopScan ?? 'Stop Scan')
//                       : (AppLocalizations.of(context)?.startScan ??
//                           'Start Scan'),
//                 ),
//               ),
//             ],
//           ),
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF356033).withOpacity(0.05),
//                   Colors.white,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Smaller Camera Scanner Section
//                 if (_scanning)
//                   Container(
//                     margin: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 10,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: SizedBox(
//                         height: 150, // Smaller camera area
//                         child: MobileScanner(
//                           controller: scannerController,
//                           onDetect: (capture) {
//                             if (capture.barcodes.isEmpty) return;
//                             final barcode = capture.barcodes.first.rawValue;
//                             if (_pendingScanCode == null && barcode != null) {
//                               _pendingScanCode = barcode;
//                               context
//                                   .read<ItemBloc>()
//                                   .add(SearchItemByCodeEvent(barcode));
//                             }
//                           },
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Improved Table Section
//                 Expanded(
//                   child: Container(
//                     margin: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0xFF356033).withOpacity(0.1),
//                           blurRadius: 15,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Table Header with Count
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF356033),
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                               topRight: Radius.circular(16),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.inventory_2_outlined,
//                                 color: Colors.white,
//                                 size: 22,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 'Scanned Items',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               Spacer(),
//                               if (scannedItems.isNotEmpty)
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   child: Text(
//                                     '${scannedItems.length} item${scannedItems.length != 1 ? 's' : ''}',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),

//                         // Clean and Simple Table Content
//                         Expanded(
//                           child: scannedItems.isEmpty
//                               ? Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.qr_code_2,
//                                         size: 80,
//                                         color: Colors.grey[300],
//                                       ),
//                                       SizedBox(height: 16),
//                                       Text(
//                                         'No items scanned yet',
//                                         style: TextStyle(
//                                           color: Colors.grey[600],
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         'Press the play button to start scanning',
//                                         style: TextStyle(
//                                           color: Colors.grey[500],
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   padding: EdgeInsets.zero,
//                                   itemCount: scannedItems.length,
//                                   itemBuilder: (context, index) {
//                                     final item = scannedItems[index];
//                                     final isEven = index % 2 == 0;

//                                     return Container(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 16, vertical: 12),
//                                       decoration: BoxDecoration(
//                                         color: isEven
//                                             ? Colors.white
//                                             : Color(0xFF356033)
//                                                 .withOpacity(0.03),
//                                         border: Border(
//                                           bottom: BorderSide(
//                                             color: Color(0xFF356033)
//                                                 .withOpacity(0.1),
//                                             width: 0.5,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           // Code Column
//                                           Expanded(
//                                             flex: 3,
//                                             child: Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   vertical: 8, horizontal: 12),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFF356033)
//                                                     .withOpacity(0.1),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: Text(
//                                                 item.code,
//                                                 style: TextStyle(
//                                                   fontFamily: 'monospace',
//                                                   fontSize: 13,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Color(0xFF356033),
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 12),

//                                           // Product Name Column
//                                           Expanded(
//                                             flex: 5,
//                                             child: Text(
//                                               item.label,
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.grey[800],
//                                               ),
//                                               overflow: TextOverflow.ellipsis,
//                                               maxLines: 2,
//                                             ),
//                                           ),
//                                           SizedBox(width: 12),

//                                           // Quantity Column
//                                           Expanded(
//                                             flex: 2,
//                                             child: Container(
//                                               padding: EdgeInsets.symmetric(
//                                                   vertical: 6, horizontal: 12),
//                                               decoration: BoxDecoration(
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     Color(0xFF356033),
//                                                     Color(0xFF2D5129),
//                                                   ],
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                               ),
//                                               child: Text(
//                                                 item.quantity ==
//                                                         item.quantity.toInt()
//                                                     ? '${item.quantity.toInt()}'
//                                                     : '${item.quantity}',
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.white,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                         ),

//                         // Save Button at the Bottom
//                         if (scannedItems.isNotEmpty)
//                           Container(
//                             padding: EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(16),
//                                 bottomRight: Radius.circular(16),
//                               ),
//                               border: Border(
//                                 top: BorderSide(
//                                   color: Color(0xFF356033).withOpacity(0.1),
//                                   width: 1,
//                                 ),
//                               ),
//                             ),
//                             child: SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: ElevatedButton.icon(
//                                 onPressed: _saveItems,
//                                 icon: Icon(
//                                   Icons.save_rounded,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                                 label: Text(
//                                   AppLocalizations.of(context)?.saveBatch ??
//                                       'Save Batch',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Color(0xFF356033),
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 3,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
