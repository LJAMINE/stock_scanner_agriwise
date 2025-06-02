import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';

class ItemExcelImporter {
  /// Lets the user pick an Excel file and returns the parsed Item list or error.
  static Future<(List<Item>?, String?)> pickAndParseExcel() async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
      if (result == null || result.files.single.path == null) {
        return (null, "No file selected.");
      }

      final fileBytes = File(result.files.single.path!).readAsBytesSync();
      final excel = Excel.decodeBytes(fileBytes);
      final sheet = excel.sheets.values.first;
      final rows = sheet.rows;

      if (rows.length < 2) {
        return (null, "Excel file must have at least one data row.");
      }

      final header =
          rows[0].map((cell) => cell?.value?.toString().toLowerCase()).toList();
      final codeIdx = header.indexOf("code");
      final labelIdx = header.indexOf("label");
      final descIdx = header.indexOf("description");
      final dateIdx = header.indexOf("date");
      final qtyIdx = header.indexOf("quantity");

      if ([codeIdx, labelIdx, descIdx, dateIdx, qtyIdx].contains(-1)) {
        return (
          null,
          "Excel must contain columns: code, label, description, date, quantity."
        );
      }

      final items = <Item>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 5) continue;

        final code = row[codeIdx]?.value?.toString() ?? '';
        final label = row[labelIdx]?.value?.toString() ?? '';
        final description = row[descIdx]?.value?.toString() ?? '';
        final date = row[dateIdx]?.value?.toString() ?? '';
        final quantity =
            int.tryParse(row[qtyIdx]?.value?.toString() ?? '0') ?? 0;

        if (code.isEmpty || label.isEmpty) continue;

        items.add(Item(
          code: code,
          label: label,
          description: description,
          date: date,
          quantity: quantity,
        ));
      }

      if (items.isEmpty) {
        return (null, "No valid items found in Excel file.");
      }

      return (items, null);
    } catch (e) {
      return (null, "Error: ${e.toString()}");
    }
  }
}
