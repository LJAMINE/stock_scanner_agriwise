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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF356033),
              Color(0xFF2D5129),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF356033).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
          ),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2_rounded),
              ),
              label: 'Items',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.qr_code_scanner_rounded),
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.archive_rounded),
              ),
              label: 'Archive',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 3
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.settings_rounded),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
