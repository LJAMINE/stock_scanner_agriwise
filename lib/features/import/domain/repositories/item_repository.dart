import '../entities/item.dart';

abstract class ItemRepository {
  Future<void> importItems(List<Item> items);

  Future<List<Item>> getAllItems();
}
