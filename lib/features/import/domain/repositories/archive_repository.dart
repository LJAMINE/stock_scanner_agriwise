import '../entities/archive_batch.dart';

abstract class ArchiveRepository {
  Future<void> saveBatch(ArchiveBatch batch);
  Future<List<ArchiveBatch>> getArchivedBatches();
}
