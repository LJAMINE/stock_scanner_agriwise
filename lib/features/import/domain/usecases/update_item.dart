import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

class UpdateItem {
  final ItemRepository repository;
  UpdateItem(this.repository);

  Future<void> call(Item item) {
    return repository.updateItem(item);
  }
}
