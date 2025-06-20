import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/core/util/editItemDialog.dart';
import 'package:flutter_stock_scanner/core/util/scan_mode_prefs.dart';
import 'package:flutter_stock_scanner/core/util/startScan.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/scanner_page.dart';
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
  List<Item> _items = []; // Only for export, do not use for UI display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => Navigator.pushNamed(context, '/import'),
          ),
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: () => startScan(context),

            // onPressed: () => Navigator.pushNamed(context, '/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Get the latest items from Bloc state for export
              final state = context.read<ItemBloc>().state;
              if (state is ItemsLoaded) {
                _items = state.items;
                context.read<ItemBloc>().add(ExportItemsEvent(_items));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No items to export.")),
                );
              }
            },
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Change Scan Mode',
            onPressed: () async {
              await clearScanMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Scan mode preference cleared! Next scan will ask again.'),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Amine lm"),
              accountEmail: Text("amine@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
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
                  leading: Icon(Icons.settings),
                  title: Text("scan mode: $scanModeText"),
                  onTap: () async {
                    bool? useCamera = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("select scan mode"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text("Use Camera"),
                              onTap: () => Navigator.pop(ctx, true),
                            ),
                            ListTile(
                              leading: Icon(Icons.scanner),
                              title: Text("Use Hardware Scanner"),
                              onTap: () => Navigator.pop(ctx, false),
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
                        ),
                      );
                    }
                    Navigator.pop(context); // Close drawer
                  },
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              subtitle: Text("View and edit your profile"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Profile"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Name: Amine lm"),
                        Text("amine@gmail.com"),
                        SizedBox(height: 10),
                        Text("this is a demo profile"),
                      ],
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              subtitle: Text("Learn more about this app"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("About"),
                    content: Text(
                        "This app is a demo for managing items with barcode scanning capabilities."),
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
                return ListTile(
                  title: Text(item.label),
                  subtitle: Text('Code: ${item.code} | Qty: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
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
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Item"),
                              content: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<ItemBloc>()
                                        .add(DeleteItemEvent(item.code));
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
