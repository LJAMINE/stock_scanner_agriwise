import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveScanMode(bool useCamera) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('useCamera', useCamera);
}

Future<bool?> loadScanMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('useCamera');
}

Future<void> clearScanMode() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('useCamera');
}

Future<bool?> showScanModeDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text("Choose Scan Mode"),
      
      children: [
        SimpleDialogOption(
          child: const Text('Use Camera'),
          onPressed: () => Navigator.pop(context, true),
        ),
        SimpleDialogOption(
          child: const Text('Use Hardware Scanner'),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
}
