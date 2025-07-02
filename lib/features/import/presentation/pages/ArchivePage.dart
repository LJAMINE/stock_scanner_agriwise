import 'package:flutter/material.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/archive_batch.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/archive_local_data_source_impl.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/archive_repository_impl.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  late final Future<List<ArchiveBatch>> _batchesFuture =
      ArchiveRepositoryImpl(localDataSource: ArchiveLocalDataSourceImpl())
          .getArchivedBatches();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<ArchiveBatch>>(
        future: _batchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No archived batches.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final batches = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  title: Text(
                    'Batch: ${_formatDate(batch.date)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Items: ${batch.items.length}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.blue.shade400),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => _BatchDetailSheet(batch: batch),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _BatchDetailSheet extends StatelessWidget {
  final ArchiveBatch batch;
  const _BatchDetailSheet({required this.batch});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Batch: ${batch.date.toLocal()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: batch.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, idx) {
                  final item = batch.items[idx];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2_outlined,
                        color: Colors.blue),
                    title: Text(item.label,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Code: ${item.code}\nQty: ${item.quantity}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
