import 'package:flutter/material.dart';
import 'package:flutter_stock_scanner/core/util/scan_mode_prefs.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/scanner_page.dart';

Future<void> startScan(BuildContext context) async {
  bool? useCamera = await loadScanMode();
  if (useCamera == null) {
    useCamera = await showScanModeDialog(context);
    if (useCamera != null) {
      await saveScanMode(useCamera);
    } else {
      // User cancelled dialog
      return;
    }
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ScannerPage(useCamera: useCamera!),
    ),
  );
}
