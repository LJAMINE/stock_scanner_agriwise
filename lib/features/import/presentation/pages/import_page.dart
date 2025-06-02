import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';

import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _loading = false;
  String? _error;
  List<Item>? _previewItems;

  Future<void> _pickAndImportExcel() async {
    setState(() {
      _loading = true;
      _error = null;
      _previewItems = null;
    });

    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
      if (result == null || result.files.single.path == null) {
        setState(() {
          _loading = false;
          _error = "No file selected.";
        });

        return;
      }

      final fileBytes = File(result.files.single.path!).readAsBytesSync();
      final excel = Excel.decodeBytes(fileBytes);

      // Assume the first sheet and a header row
      final sheet = excel.sheets.values.first;
      final rows = sheet.rows;

      if (rows.length < 2) {
        setState(() {
          _loading = false;
          _error = "Excel file must have at least one data row.";
        });
        return;
      }

      // Map header indexes
      final header =
          rows[0].map((cell) => cell?.value?.toString().toLowerCase()).toList();
      final codeIdx = header.indexOf("code");
      final labelIdx = header.indexOf("label");
      final descIdx = header.indexOf("description");
      final dateIdx = header.indexOf("date");
      final qtyIdx = header.indexOf("quantity");

      if ([codeIdx, labelIdx, descIdx, dateIdx, qtyIdx].contains(-1)) {
        setState(() {
          _loading = false;
          _error =
              "Excel must contain columns: code, label, description, date, quantity.";
        });
        return;
      }

      // Build items list
      final items = <Item>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 5) continue; // skip incomplete rows

        final code = row[codeIdx]?.value?.toString() ?? '';
        final label = row[labelIdx]?.value?.toString() ?? '';
        final description = row[descIdx]?.value?.toString() ?? '';
        final date = row[dateIdx]?.value?.toString() ?? '';
        final quantity =
            int.tryParse(row[qtyIdx]?.value?.toString() ?? '0') ?? 0;

        if (code.isEmpty || label.isEmpty) continue; // skip invalid

        items.add(Item(
          code: code,
          label: label,
          description: description,
          date: date,
          quantity: quantity,
        ));
      }

      if (items.isEmpty) {
        setState(() {
          _loading = false;
          _error = "No valid items found in Excel file.";
        });
        return;
      }

      setState(() {
        _loading = false;
        _error = null;
        _previewItems = items;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Error: ${e.toString()}";
      });
    }
  }

  void _confirmImport() {
    if (_previewItems == null || _previewItems!.isEmpty) return;
    context.read<ItemBloc>().add(ImportItemsEvent(_previewItems!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: (context, state) {
        if (state is ItemImported) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Import successful!")));
          Navigator.pop(context);
        }
        if (state is ItemError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Import failed: ${state.message}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Import items from excel'),
          centerTitle: true,
        ),
        body: Padding(
            padding: EdgeInsets.all(17),
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickAndImportExcel,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Choose Excel File"),
                      ),
                      if (_error != null) ...[
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      if (_previewItems != null) ...[
                        const SizedBox(height: 16),
                        const Text("Preview (first 5 rows):"),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _previewItems!.length > 5
                                ? 5
                                : _previewItems!.length,
                            itemBuilder: (context, index) {
                              final item = _previewItems![index];

                              return ListTile(
                                title: Text(item.label),
                                subtitle: Text(
                                    'Code: ${item.code} | Qty: ${item.quantity}'),
                              );
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("Import"),
                          onPressed: _confirmImport,
                        )
                      ]
                    ],
                  )),
      ),
    );
  }
}
