import '../entities/item.dart';

abstract class ItemRepository {
  Future<void> importItems(List<Item> items);

  Future<List<Item>> getAllItems();

  Future<void> updateItem(Item item);

  Future<void> deleteItem(String code);

  Future<Item?> getItemByCode(String code);

  Future<String> exportItemsToExcel(List<Item> items);
}
