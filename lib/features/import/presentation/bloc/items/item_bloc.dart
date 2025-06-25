import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/delete_item.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/export_items_to_excel.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_all_items.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_item_by_code.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/import_items.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/saveBatchToArchive.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/update_item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final ImportItems importItems;
  final GetAllItems getAllItems;
  final UpdateItem updateItemUseCase;
  final DeleteItem deleteItemUseCase;
  final GetItemByCode getItemByCode;
  final ExportItemsToExcel exportItemsToExcelUseCase;
  final SaveBatchToArchive saveBatchToArchiveUseCase;

  ItemBloc({
    required this.importItems,
    required this.getAllItems,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
    required this.getItemByCode,
    required this.exportItemsToExcelUseCase,
    required this.saveBatchToArchiveUseCase,
  }) : super(ItemInitial()) {
    on<ResetItemState>((event, emit) => emit(ItemInitial()));

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

    on<UpdateItemEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await updateItemUseCase(event.item);
        emit(ItemUpdated());
        final items = await getAllItems();
        emit(ItemsLoaded(items));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<DeleteItemEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        await deleteItemUseCase(event.code);
        emit(ItemDeleted());
        final items = await getAllItems();
        emit(ItemsLoaded(items));
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<SearchItemByCodeEvent>((event, emit) async {
      print(
          '####################BLOC: SearchItemByCodeEvent for code: ${event.code}');
      emit(ItemLoading());
      try {
        final item = await getItemByCode(event.code);
        print('####################BLOC: getItemByCode returned: $item');
        if (item != null) {
          emit(ItemFound(item));
        } else {
          emit(ItemNotFound(event.code));
        }
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });

    on<ExportItemsEvent>((event, emit) async {
      try {
        final filePath = await exportItemsToExcelUseCase(event.items);
        emit(ExportSuccess(filePath));
      } catch (e) {
        emit(ExportFailure(e.toString()));
      }
    });

    on<SaveBatchToArchiveEvent>((event, emit) async {
      emit(ItemLoading());
      try {
        saveBatchToArchiveUseCase(event.items, event.date);
        emit(BatchSavedSuccess());
      } catch (e) {
        emit(ItemError(e.toString()));
      }
    });
  }
}
