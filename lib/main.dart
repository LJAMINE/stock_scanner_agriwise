import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/archive_local_data_source_impl.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/item_local_datasource.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/profile_local_data_source_impl.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/archive_repository_impl.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/profile_repository_impl.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/delete_item.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/export_items_to_excel.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_item_by_code.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/saveBatchToArchive.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/update_item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_state.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ArchivePage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/import_page.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/main_navigation.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ProfilePage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/item_repository_impl.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/import_items.dart';
import 'package:flutter_stock_scanner/features/import/domain/usecases/get_all_items.dart';

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
    // Archive dependencies
    final archiveLocalDataSource = ArchiveLocalDataSourceImpl();
    final archiveRepository =
        ArchiveRepositoryImpl(localDataSource: archiveLocalDataSource);
    final saveBatchToArchiveUseCase = SaveBatchToArchive(archiveRepository);

    // Profile dependencies
    final profileLocalDataSource = ProfileLocalDataSourceImpl();
    final profileRepository = ProfileRepositoryImpl(profileLocalDataSource);

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
              saveBatchToArchiveUseCase:
                  saveBatchToArchiveUseCase, // <-- add this
            )..add(GetAllItemsEvent()), // Load items on start
          ),
          BlocProvider<LanguageBloc>(
            create: (_) => LanguageBloc(),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(profileRepository),
          ),
        ],
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            return MaterialApp(
              locale: langState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              debugShowCheckedModeBanner: false,
              title: 'Stock Scanner',
              theme: ThemeData(primarySwatch: Colors.blue),
              initialRoute: '/',
              routes: {
                '/': (context) => const MainNavigation(),
                '/import': (context) => const ImportPage(),
                '/archive': (context) => const ArchivePage(),
                '/profile': (context) => const ProfilePage(),
                // '/scanner': (context) => const ScannerPage(),
                // Add '/scanner': (context) => ScannerPage(), later
              },
            );
          },
        ));
  }
}
