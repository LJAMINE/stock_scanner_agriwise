import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

class ExportItemsToExcel {
  final ItemRepository repository;

  ExportItemsToExcel(this.repository);

  Future<String> call(List<Item> items) async {
    return await repository.exportItemsToExcel(items);
  }
}
