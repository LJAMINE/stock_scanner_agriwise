import 'package:flutter_stock_scanner/features/import/domain/entities/archive_batch.dart';

abstract class ArchiveLocalDataSource {
  Future<void> saveBatch(ArchiveBatch batch);
  Future<List<ArchiveBatch>> getArchivedBatches();
}
