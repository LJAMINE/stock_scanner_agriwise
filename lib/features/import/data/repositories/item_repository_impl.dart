import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/item_local_datasource.dart';
import 'package:flutter_stock_scanner/features/import/data/models/item_model.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource localDataSource;

  ItemRepositoryImpl({required this.localDataSource});

  @override
  Future<void> importItems(List<Item> items) async {
    final itemModels = items
        .map(
          (item) => ItemModel(
              code: item.code,
              label: item.label,
              description: item.description,
              date: item.date,
              quantity: item.quantity),
        )
        .toList();

    await localDataSource.insertItems(itemModels);
  }

  @override
  Future<List<Item>> getAllItems() async {
    return await localDataSource.getAllItems();
  }

  @override
  Future<void> deleteItem(String code) => localDataSource.deleteItem(code);

  @override
  Future<void> updateItem(Item item) => localDataSource.updateItem(ItemModel(
        code: item.code,
        label: item.label,
        description: item.description,
        date: item.date,
        quantity: item.quantity,
      ));

  @override
  Future<Item?> getItemByCode(String code) async {
    return await localDataSource.getItemByCode(code);
  }

  @override
  Future<String> exportItemsToExcel(List<Item> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Items'];

    sheet.appendRow([
      TextCellValue('Code'),
      TextCellValue('Label'),
      TextCellValue('Description'),
      TextCellValue('Date'),
      TextCellValue('Quantity'),
    ]);
    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.code),
        TextCellValue(item.label),
        TextCellValue(item.description ?? ''),
        TextCellValue(item.date ?? ''),
        IntCellValue(item.quantity ?? 0),
      ]);
    }

    final excelBytes = excel.save();
    if (excelBytes == null) throw Exception('Failed to generate Excel file.');

    final result = await FileSaver.instance.saveFile(
      name: "exported_items",
      bytes: Uint8List.fromList(excelBytes),
      ext: "xlsx",
      mimeType: MimeType.microsoftExcel,
    );

    if (result.isNotEmpty) {
      await OpenFilex.open(
          result); // This will prompt the user to open the file with Excel or another app
    }

    return result ?? "Exported successfully";
  }
}
