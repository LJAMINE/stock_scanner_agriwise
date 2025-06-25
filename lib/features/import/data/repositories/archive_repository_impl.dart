import 'package:flutter_stock_scanner/features/import/data/data_sources/archive_local_data_source.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/archive_batch.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ArchiveLocalDataSource localDataSource;
  ArchiveRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveBatch(ArchiveBatch batch) async {
    await localDataSource.saveBatch(batch);
  }

  @override
  Future<List<ArchiveBatch>> getArchivedBatches() async {
    return await localDataSource.getArchivedBatches();
  }
}
