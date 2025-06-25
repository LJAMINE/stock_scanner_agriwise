import 'package:flutter_stock_scanner/features/import/domain/entities/archive_batch.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/domain/repositories/archive_repository.dart';

class SaveBatchToArchive {
  final ArchiveRepository repository;
  SaveBatchToArchive(this.repository);

  Future<void> call(List<Item> items, DateTime date) {
    final batch = ArchiveBatch(date: date, items: items);
    return repository.saveBatch(batch);
  }
}
