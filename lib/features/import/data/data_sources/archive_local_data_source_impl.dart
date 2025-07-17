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
    print(
        'DEBUG: saveBatch called with ${batch.items.length} items, date: ${batch.date}');
    final prefs = await SharedPreferences.getInstance();
    final List<String> batches = prefs.getStringList(archiveKey) ?? [];
    print('DEBUG: Current batches count: ${batches.length}');
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
    print(
        'DEBUG: Batch saved successfully. New batches count: ${batches.length}');
  }

  @override
  Future<List<ArchiveBatch>> getArchivedBatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> batches = prefs.getStringList(archiveKey) ?? [];
      print(
          'DEBUG: getArchivedBatches called, found ${batches.length} batches');

      final List<ArchiveBatch> result = [];
      for (int i = 0; i < batches.length; i++) {
        try {
          final batchStr = batches[i];
          print('DEBUG: Parsing batch $i: ${batchStr.substring(0, 100)}...');
          final map = jsonDecode(batchStr);
          final batch = ArchiveBatch(
            date: DateTime.parse(map['date']),
            items: (map['items'] as List)
                .map((item) => ItemModel.fromJson(item))
                .toList(),
          );
          result.add(batch);
          print(
              'DEBUG: Successfully parsed batch $i with ${batch.items.length} items');
        } catch (e) {
          print('DEBUG: Error parsing batch $i: $e');
        }
      }

      // Sort batches by date in descending order (latest first)
      result.sort((a, b) => b.date.compareTo(a.date));
      print(
          'DEBUG: Returning ${result.length} successfully parsed batches (sorted by date desc)');
      return result;
    } catch (e) {
      print('DEBUG: Error in getArchivedBatches: $e');
      return [];
    }
  }

  // Method to clear all archived batches for testing
  Future<void> clearAllBatches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(archiveKey);
    print('DEBUG: All archived batches cleared');
  }
}
