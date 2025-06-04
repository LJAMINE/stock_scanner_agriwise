import 'package:flutter_stock_scanner/features/import/data/data_sources/item_local_datasource.dart';
import 'package:flutter_stock_scanner/features/import/data/models/item_model.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/item_repository.dart';

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
}
