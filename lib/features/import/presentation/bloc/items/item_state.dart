import 'package:equatable/equatable.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemsLoaded extends ItemState {
  final List<Item> items;

  const ItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ItemImported extends ItemState {}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}

class ItemUpdated extends ItemState {}

class ItemDeleted extends ItemState {}

class ItemFound extends ItemState {
  final Item item;
  const ItemFound(this.item);
}

class ItemNotFound extends ItemState {
  final String code;
  const ItemNotFound(this.code);
}
