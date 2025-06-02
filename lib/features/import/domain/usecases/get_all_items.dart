import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetAllItems {
  final ItemRepository repository;

  GetAllItems(this.repository);

  Future<List<Item>> call() async {
    return await repository.getAllItems();
  }
}