import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;
  DeleteItem(this.repository);

  Future<void> call(String code) {
    return repository.deleteItem(code);
  }
}
