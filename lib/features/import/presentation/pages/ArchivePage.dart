import 'package:flutter/material.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/archive_batch.dart';
import 'package:flutter_stock_scanner/features/import/data/data_sources/archive_local_data_source_impl.dart';
import 'package:flutter_stock_scanner/features/import/data/repositories/archive_repository_impl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' as ExcelPackage;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> with WidgetsBindingObserver {
  late ArchiveRepositoryImpl _archiveRepository;
  Future<List<ArchiveBatch>>? _batchesFuture;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _archiveRepository =
        ArchiveRepositoryImpl(localDataSource: ArchiveLocalDataSourceImpl());
    WidgetsBinding.instance.addObserver(this);
    _loadBatches();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('ArchivePage: App resumed - refreshing data');
      _loadBatches();
    }
  }

  // This will be called whenever the widget is built,
  // including when it becomes visible via IndexedStack
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoaded) {
      // Only refresh if we've loaded before (means we're coming back to this page)
      print('ArchivePage: Dependencies changed - refreshing data');
      _loadBatches();
    }
    _hasLoaded = true;
  }

  void _loadBatches() {
    setState(() {
      _batchesFuture = _archiveRepository.getArchivedBatches();
    });
  }

  Future<void> _refreshBatches() async {
    _loadBatches();
  }

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
        child: RefreshIndicator(
          onRefresh: _refreshBatches,
          color: Color(0xFF356033),
          child: FutureBuilder<List<ArchiveBatch>>(
            future: _batchesFuture,
            builder: (context, snapshot) {
              print(
                  'DEBUG: FutureBuilder - connectionState: ${snapshot.connectionState}');
              print('DEBUG: FutureBuilder - hasData: ${snapshot.hasData}');
              print(
                  'DEBUG: FutureBuilder - data length: ${snapshot.data?.length ?? 'null'}');
              print('DEBUG: FutureBuilder - hasError: ${snapshot.hasError}');
              if (snapshot.hasError) {
                print('DEBUG: FutureBuilder - error: ${snapshot.error}');
              }

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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF356033)),
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
                                  fontSize: 12,
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
                          // Since batches are sorted newest first, we want newest to have highest number
                          final batchNumber = batches.length - index;
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
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                      SizedBox(width: 7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Batch #$batchNumber',
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
                                                fontSize: 12,
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
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Export button
                                          Container(
                                            margin: EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF356033)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.file_download_rounded,
                                                size: 18,
                                                color: Color(0xFF356033),
                                              ),
                                              onPressed: () =>
                                                  _exportBatchToExcel(
                                                      batch, batchNumber),
                                              tooltip: 'Export Batch',
                                              padding: EdgeInsets.all(8),
                                              constraints: BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                            ),
                                          ),
                                          // View details button
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF356033)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.visibility_rounded,
                                                size: 18,
                                                color: Color(0xFF356033),
                                              ),
                                              onPressed: () =>
                                                  _showBatchDetails(
                                                      context, batch),
                                              tooltip: 'View Details',
                                              padding: EdgeInsets.all(8),
                                              constraints: BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                            ),
                                          ),
                                        ],
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
      ),
    );
  }

  void _showBatchDetails(BuildContext context, ArchiveBatch batch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BatchDetailSheet(
        batch: batch,
        onExport: (batch) {
          // Find the batch index for export and calculate correct batch number
          _batchesFuture?.then((batches) {
            final index = batches.indexOf(batch);
            final batchNumber =
                batches.length - index; // Newest gets highest number
            _exportBatchToExcel(batch, batchNumber);
          });
        },
      ),
    );
  }

  // Export batch to Excel file
  Future<void> _exportBatchToExcel(ArchiveBatch batch, int batchNumber) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF356033)),
              ),
              SizedBox(height: 16),
              Text(
                'Exporting Batch #$batchNumber...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF356033),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final excel = ExcelPackage.Excel.createExcel();
      final sheet = excel['Batch_$batchNumber'];

      // Add header with only required columns
      sheet.appendRow([
        ExcelPackage.TextCellValue('Code'),
        ExcelPackage.TextCellValue('Label'),
        ExcelPackage.TextCellValue('Quantity'),
      ]);

      // Add batch items with only required columns
      for (final item in batch.items) {
        sheet.appendRow([
          ExcelPackage.TextCellValue(item.code),
          ExcelPackage.TextCellValue(item.label),
          ExcelPackage.DoubleCellValue(item.quantity),
        ]);
      }

      final excelBytes = excel.save();
      if (excelBytes == null) throw Exception('Failed to generate Excel file.');

      // Format the date for filename: DD/MM/YYYY becomes DD-MM-YYYY
      final dateStr =
          '${batch.date.day.toString().padLeft(2, '0')}-${batch.date.month.toString().padLeft(2, '0')}-${batch.date.year}';

      final filePath = await FileSaver.instance.saveFile(
        name: 'batch_${batchNumber}_$dateStr',
        bytes: Uint8List.fromList(excelBytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      // Close loading dialog
      Navigator.pop(context);

      _showExportSuccessDialog(filePath, batch, batchNumber);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Show export success dialog with action options
  void _showExportSuccessDialog(
      String filePath, ArchiveBatch batch, int batchNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF356033), Color(0xFF2D5129)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.file_download,
                          color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF356033),
                            ),
                          ),
                          Text(
                            'Batch $batchNumber ${_formatDateShort(batch.date)} exported successfully',
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
              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildActionButton(
                      icon: Icons.open_in_new,
                      title: 'Open File',
                      subtitle: 'Open the Excel file',
                      onTap: () {
                        Navigator.pop(context);
                        OpenFilex.open(filePath);
                      },
                    ),
                    SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.folder_open,
                      title: 'Save to Downloads',
                      subtitle: 'Choose location to save',
                      onTap: () async {
                        Navigator.pop(context);
                        await _saveToCustomLocation(filePath);
                      },
                    ),
                    SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.share,
                      title: 'Share',
                      subtitle: 'Share with others',
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await Share.shareXFiles(
                            [XFile(filePath)],
                            text:
                                'Batch $batchNumber ${_formatDateShort(batch.date)} - ${batch.items.length} items exported from AgriWise Stock Scanner',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Share failed: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Build action button widget
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF356033).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF356033)),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF356033)),
        onTap: onTap,
      ),
    );
  }

  // Save file to custom location
  Future<void> _saveToCustomLocation(String sourcePath) async {
    try {
      String? pickedDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save Excel file',
      );
      if (pickedDir != null) {
        final fileName = sourcePath.split('/').last;
        final destPath = '$pickedDir/$fileName';
        final sourceFile = File(sourcePath);
        final bytes = await sourceFile.readAsBytes();
        final destFile = File(destPath);
        await destFile.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $destPath'),
            backgroundColor: Color(0xFF356033),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File save cancelled'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _BatchDetailSheet extends StatelessWidget {
  final ArchiveBatch batch;
  final Function(ArchiveBatch)? onExport;
  const _BatchDetailSheet({required this.batch, this.onExport});

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
                  // Export button in batch detail
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF356033).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.file_download_rounded,
                        color: Color(0xFF356033),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the sheet first
                        onExport?.call(batch); // Call the export callback
                      },
                      tooltip: 'Export Batch',
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
                                  'Qty: ${item.quantity == item.quantity.toInt() ? item.quantity.toInt() : item.quantity}',
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
