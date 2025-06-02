import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

class ImportItems {
  final ItemRepository repository;

  ImportItems(this.repository);

  Future<void> call(List<Item> items) async {
    return repository.importItems(items);
  }
}
