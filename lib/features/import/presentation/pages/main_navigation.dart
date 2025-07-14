import 'package:flutter/material.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/item_page.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ScanPage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ArchivePage.dart';
import 'package:flutter_stock_scanner/features/import/presentation/pages/ParametrePage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ItemPage(), // Use the existing ItemPage (now without bottom nav)
    ScanPage(),
    ArchivePage(),
    ParametrePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Items'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archive'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Parametre'),
        ],
      ),
    );
  }
}
