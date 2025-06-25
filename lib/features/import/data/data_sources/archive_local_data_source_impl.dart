import 'dart:convert';
import 'package:flutter_stock_scanner/features/import/data/models/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/archive_batch.dart';
import '../../domain/entities/item.dart';
import 'archive_local_data_source.dart';

class ArchiveLocalDataSourceImpl implements ArchiveLocalDataSource {
  static const String archiveKey = 'archived_batches';

  @override
  Future<void> saveBatch(ArchiveBatch batch) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> batches = prefs.getStringList(archiveKey) ?? [];
    batches.add(jsonEncode({
      'date': batch.date.toIso8601String(),
      'items': batch.items
          .map((item) => ItemModel(
                code: item.code,
                label: item.label,
                description: item.description,
                date: item.date,
                quantity: item.quantity,
                imageBase64: item.imageBase64,
              ).toJson())
          .toList(),
    }));
    await prefs.setStringList(archiveKey, batches);
  }

  @override
  Future<List<ArchiveBatch>> getArchivedBatches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> batches = prefs.getStringList(archiveKey) ?? [];
    return batches.map((batchStr) {
      final map = jsonDecode(batchStr);
      return ArchiveBatch(
        date: DateTime.parse(map['date']),
        items: (map['items'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList(),
      );
    }).toList();
  }
}
