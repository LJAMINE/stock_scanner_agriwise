import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

class GetItemByCode {
  final ItemRepository repository;
  GetItemByCode(this.repository);

  Future<Item?> call(String code) async {
    return await repository.getItemByCode(code);
  }
}
