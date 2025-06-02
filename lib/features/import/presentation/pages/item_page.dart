import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_event.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/items/item_state.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Items")),
      body: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemsLoaded) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, idx) {
                final item = state.items[idx];
                return ListTile(
                  title: Text(item.label),
                  subtitle: Text('Code: ${item.code} | Qty: ${item.quantity}'),
                  trailing: Text(item.date),
                );
              },
            );
          } else if (state is ItemError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No Data'));
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: () {
              context.read<ItemBloc>().add(GetAllItemsEvent());
            },
            tooltip: "Refresh",
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "import",
            onPressed: () {
              Navigator.pushNamed(context, '/import');
            },
            tooltip: "Import from Excel",
            child: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }
}
