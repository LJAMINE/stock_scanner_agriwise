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
        title: const Text(
          'Archive History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF356033),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF356033),
                Color(0xFF2D5129),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF356033).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<List<ArchiveBatch>>(
          future: _batchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF356033).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF356033)),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Loading Archive...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF356033),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Color(0xFF356033).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.archive_rounded,
                          size: 80,
                          color: Color(0xFF356033),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'No Archive Yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF356033),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your archived batches will appear here after scanning and saving items',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF356033).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color(0xFF356033).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFF356033),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Start scanning to create your first batch',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF356033),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final batches = snapshot.data!;
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF356033),
                          Color(0xFF2D5129),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF356033).withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Archive History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${batches.length} saved batches',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${batches.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF356033),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: batches.length,
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF356033).withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showBatchDetails(context, batch),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF356033),
                                            Color(0xFF2D5129),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '#${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            Icons.archive_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Batch #${index + 1}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF356033),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${batch.items.length} items',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 16,
                                                color: Colors.grey[500],
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _formatDate(batch.date),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFF356033).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Color(0xFF356033),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBatchDetails(BuildContext context, ArchiveBatch batch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BatchDetailSheet(batch: batch),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _BatchDetailSheet extends StatelessWidget {
  final ArchiveBatch batch;
  const _BatchDetailSheet({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF356033),
                          Color(0xFF2D5129),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.archive_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF356033),
                          ),
                        ),
                        Text(
                          '${batch.items.length} items • ${_formatDate(batch.date)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Items List
            Container(
              height: 400,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items in this batch:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF356033),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: batch.items.length,
                      itemBuilder: (context, idx) {
                        final item = batch.items[idx];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF356033).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF356033).withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF356033).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${idx + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF356033),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Code: ${item.code}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF356033),
                                      Color(0xFF2D5129),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
