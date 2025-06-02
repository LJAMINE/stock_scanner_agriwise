import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_all_items.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/import_items.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final ImportItems importItems;
  final GetAllItems getAllItems;

  ItemBloc({required this.importItems, required this.getAllItems})
      : super(ItemInitial()) {
    on<ImportItemsEvent>((event, emit) async {
      emit(ItemLoading());

      try {
        await importItems(event.items);
        emit(ItemImported());

        final items = await getAllItems();
        emit(ItemsLoaded(items));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<GetAllItemsEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        final items = await getAllItems();
        emit(ItemsLoaded(items));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });
  }
}
