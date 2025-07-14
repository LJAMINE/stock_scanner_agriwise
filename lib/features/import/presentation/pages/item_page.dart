import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/ItemExcelImporter.dart';
import 'package:flutter_stock_scanner/core/util/editItemDialog.dart';
import 'package:flutter_stock_scanner/core/util/imagebase64.dart';
import 'package:flutter_stock_scanner/core/util/scan_mode_prefs.dart';
import 'package:flutter_stock_scanner/core/util/startScan.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/profile_state.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ArchivePage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ParametrePage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ScanPage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/scanner_page.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_filex/open_filex.dart';
// Add this import at the top with the others:
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
// import 'package:share_plus/src/x_file.dart';
import 'package:path_provider/path_provider.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final List<Item> _items = []; // Only for export, do not use for UI display

  @override
  void initState() {
    super.initState();
    // Load profile data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadProfileEvent());
      }
    });
  }

  Future<void> _pickExcelFile(BuildContext context) async {
    final (items, err) = await ItemExcelImporter.pickAndParseExcel();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    if (items != null && items.isNotEmpty) {
      context.read<ItemBloc>().add(ImportItemsEvent(items));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Imported ${items.length} items!")),
      );
    }
  }

  void _showManualAddDialog(BuildContext context) {
    final codeController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Item manually"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Code"),
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: "Label"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              final label = labelController.text.trim();

              if (code.isNotEmpty && label.isNotEmpty) {
                final newItem = Item(
                  code: code,
                  label: label,
                  description: "",
                  date: "",
                  quantity: 0,
                );
                context.read<ItemBloc>().add(ImportItemsEvent([newItem]));
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add items manually'),
              onTap: () {
                Navigator.pop(ctx);
                _showManualAddDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Choose Excel File'),
              onTap: () {
                Navigator.pop(ctx);
                _pickExcelFile(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF356033).withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "item_page_fab",
          backgroundColor: Color(0xFF356033),
          foregroundColor: Colors.white,
          onPressed: () => _showAddOptionsDialog(context),
          icon: Icon(Icons.add_rounded, size: 24),
          label: Text(
            'Add Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Inventory Management',
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

        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.upload_file),
        //     onPressed: () => Navigator.pushNamed(context, '/import'),
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.scanner),
        //     onPressed: () => startScan(context),

        //     // onPressed: () => Navigator.pushNamed(context, '/scanner'),
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.download),
        //     onPressed: () {
        //       // Get the latest items from Bloc state for export
        //       final state = context.read<ItemBloc>().state;
        //       if (state is ItemsLoaded) {
        //         _items = state.items;
        //         context.read<ItemBloc>().add(ExportItemsEvent(_items));
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("No items to export.")),
        //         );
        //       }
        //     },
        //     tooltip: 'Export to Excel',
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     tooltip: 'Change Scan Mode',
        //     onPressed: () async {
        //       await clearScanMode();
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //           content: Text(
        //               'Scan mode preference cleared! Next scan will ask again.'),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                String name = "Guest User";
                String email = "guest@example.com";

                if (profileState is ProfileLoaded) {
                  name = profileState.profile.name.isNotEmpty
                      ? profileState.profile.name
                      : "Guest User";
                  email = profileState.profile.email.isNotEmpty
                      ? profileState.profile.email
                      : "guest@example.com";
                }

                return Container(
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
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.transparent),
                    accountName: Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: (profileState is ProfileLoaded &&
                                profileState.profile.avatarBase64 != null)
                            ? MemoryImage(base64Decode(
                                profileState.profile.avatarBase64!))
                            : null,
                        child: (profileState is! ProfileLoaded ||
                                profileState.profile.avatarBase64 == null)
                            ? Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            FutureBuilder(
              future: loadScanMode(),
              builder: (context, snapshot) {
                String scanModeText = "Not set";

                if (snapshot.hasData) {
                  scanModeText = snapshot.data == true
                      ? "Camera scanner"
                      : "Hardware Scanner";
                }
                return ListTile(
                  leading: Icon(Icons.settings, color: Color(0xFF356033)),
                  title: Text("scan mode: $scanModeText"),
                  onTap: () async {
                    bool? useCamera = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          "select scan mode",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF356033),
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF356033).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      color: Color(0xFF356033)),
                                ),
                                title: Text(
                                  "Use Camera",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  "Use your device camera to scan barcodes",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                onTap: () => Navigator.pop(ctx, true),
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF356033).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.scanner_outlined,
                                      color: Color(0xFF356033)),
                                ),
                                title: Text(
                                  "Use  Scanner",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  "Use hardware scanner to scan barcodes",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                onTap: () => Navigator.pop(ctx, false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (useCamera != null) {
                      await saveScanMode(useCamera);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Scan mode set to ${useCamera ? "Camera" : "Hardware Scanner"}'),
                          backgroundColor: Color(0xFF356033),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );

                      setState(() {});
                    }
                    Navigator.pop(context); // Close drawer
                  },
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF356033)),
              title: Text("Profile"),
              subtitle: Text("View and edit your profile"),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Color(0xFF356033)),
              title: Text("About"),
              subtitle: Text("Learn more about this app"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      "About",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF356033),
                      ),
                    ),
                    content: Text(
                      "This app is a demo for managing items with barcode scanning capabilities.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Color(0xFF356033),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          // if (state is ItemUpdated) {
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(const SnackBar(content: Text("Item updated!")));
          // }

          if (state is ItemUpdated) {
            // After an item is updated, reload all items
            context.read<ItemBloc>().add(GetAllItemsEvent());
            // Optionally show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item updated!')),
            );
          }
          if (state is ItemDeleted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Item deleted!")));
          }
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved at:\n${state.filePath}'),
                action: SnackBarAction(
                  label: 'Actions',
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.open_in_new),
                              title: const Text('Open'),
                              onTap: () {
                                OpenFilex.open(state.filePath);
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.download),
                              title: const Text('Save to Downloads'),
                              onTap: () async {
                                try {
                                  String? pickedDir = await FilePicker.platform
                                      .getDirectoryPath(
                                    dialogTitle:
                                        'Select folder to save Excel file',
                                  );
                                  if (pickedDir != null) {
                                    final fileName =
                                        state.filePath.split('/').last;
                                    final destPath = '$pickedDir/$fileName';
                                    final sourceFile = File(state.filePath);
                                    final bytes =
                                        await sourceFile.readAsBytes();
                                    final destFile = File(destPath);
                                    await destFile.writeAsBytes(bytes);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('File saved to: $destPath')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'File save cancelled or failed.')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Save failed: $e')),
                                  );
                                }
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Share'),
                              onTap: () async {
                                Navigator.pop(ctx);
                                // Use share_plus to share the file
                                try {
                                  // ignore: use_build_context_synchronously
                                  await Share.shareXFiles(
                                      [XFile(state.filePath)],
                                      text: 'Here is the exported Excel file.');
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
                    );
                  },
                ),
              ),
            );
            context.read<ItemBloc>().add(GetAllItemsEvent());
          }

          if (state is ExportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Export failed: ${state.message}")));
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemsLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text("No items found."));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () async {
                        final base64 = await pickImageAsBase64();
                        if (base64 != null) {
                          final updatedItem = Item(
                            code: item.code,
                            label: item.label,
                            description: item.description,
                            date: item.date,
                            quantity: item.quantity,
                            imageBase64: base64,
                          );
                          context
                              .read<ItemBloc>()
                              .add(UpdateItemEvent(updatedItem));
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: item.imageBase64 != null
                            ? MemoryImage(base64Decode(item.imageBase64!))
                            : null,
                        child: item.imageBase64 == null
                            ? Text(item.label.isNotEmpty
                                ? item.label[0].toUpperCase()
                                : '?')
                            : null,
                      ),
                    ),
                    title: Text(item.label,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Code: ${item.code} '),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await showDialog<Item>(
                              context: context,
                              builder: (_) => EditItemDialog(item: item),
                            );
                            if (updated != null) {
                              context
                                  .read<ItemBloc>()
                                  .add(UpdateItemEvent(updated));
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete Item"),
                                content: Text("Are you sure?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<ItemBloc>()
                                          .add(DeleteItemEvent(item.code));
                                      Navigator.pop(ctx);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ItemError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
