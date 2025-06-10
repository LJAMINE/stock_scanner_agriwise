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

class UpdateItemEvent extends ItemEvent {
  final Item item;
  const UpdateItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteItemEvent extends ItemEvent {
  final String code;
  const DeleteItemEvent(this.code);
  @override
  List<Object?> get props => [code];
}

class SearchItemByCodeEvent extends ItemEvent {
  final String code;
  const SearchItemByCodeEvent(this.code);
}

class ExportItemsEvent extends ItemEvent {
  final List<Item> items;
  const ExportItemsEvent(this.items);
}
