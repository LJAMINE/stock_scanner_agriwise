import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/item_local_datasource.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/delete_item.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/export_items_to_excel.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_item_by_code.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/update_item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/item_page.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/import_page.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/item_repository_impl.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/import_items.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_all_items.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/scanner_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up your data source, repository, and usecases
    final localDataSource = ItemLocalDataSource();
    final repository = ItemRepositoryImpl(localDataSource: localDataSource);
    final importItemsUsecase = ImportItems(repository);
    final getAllItemsUsecase = GetAllItems(repository);
    final updateItemUsecase = UpdateItem(repository);
    final deleteItemUsecase = DeleteItem(repository);
    final getItemByCode = GetItemByCode(repository);
    final exportItemsToExcelUseCase = ExportItemsToExcel(repository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemBloc>(
          create: (_) => ItemBloc(
            importItems: importItemsUsecase,
            getAllItems: getAllItemsUsecase,
            updateItemUseCase: updateItemUsecase,
            deleteItemUseCase: deleteItemUsecase,
            getItemByCode: getItemByCode,
            exportItemsToExcelUseCase: exportItemsToExcelUseCase,
          )..add(GetAllItemsEvent()), // Load items on start
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stock Scanner',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const ItemPage(),
          '/import': (context) => const ImportPage(),
          '/scanner': (context) => const ScannerPage(),
          // Add '/scanner': (context) => ScannerPage(), later
        },
      ),
    );
  }
}
