import 'package:equatable/equatable.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';






abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class ImportItemsEvent extends ItemEvent {
  final List<Item> items;

  const ImportItemsEvent(this.items);

  @override
  List<Object?> get props => [items];
}



class GetAllItemsEvent extends ItemEvent {}