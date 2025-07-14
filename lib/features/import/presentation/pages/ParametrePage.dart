import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_bloc.dart';
import 'package:flutter_stock_scanner/features/import/presentation/bloc/LanguageBloc/language_event.dart';
import 'package:flutter_stock_scanner/core/util/scan_mode_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  String? _language;
  bool? _useCamera;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final langPrefs = await SharedPreferences.getInstance();
    final lang = langPrefs.getString('language');
    final scanMode = await loadScanMode();
    setState(() {
      _language = lang;
      _useCamera = scanMode;
    });
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _language = lang;
    });
    // Dispatch language change event to LanguageBloc
    context.read<LanguageBloc>().add(ChangeLanguage(Locale(lang)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // Use a simple string instead of a non-existent localization method
          '${AppLocalizations.of(context)?.language ?? 'Language'} set to $lang',
        ),
        backgroundColor: Color(0xFF356033),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _selectScanMode() async {
    bool? useCamera = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppLocalizations.of(context)?.selectScanMode ?? 'Select scan mode',
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
                  child: Icon(Icons.camera_alt, color: Color(0xFF356033)),
                ),
                title: Text(
                  AppLocalizations.of(context)?.useCamera ?? 'Use Camera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Use your device camera to scan barcodes",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  child: Icon(Icons.scanner_outlined, color: Color(0xFF356033)),
                ),
                title: Text(
                  AppLocalizations.of(context)?.useHardwareScanner ??
                      'Use Hardware Scanner',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Use hardware scanner to scan barcodes",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      setState(() {
        _useCamera = useCamera;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // Use a simple string instead of a non-existent localization method
            '${AppLocalizations.of(context)?.scanMode ?? 'Scan mode'} set to ${useCamera ? (AppLocalizations.of(context)?.cameraScanner ?? 'Camera') : (AppLocalizations.of(context)?.hardwareScanner ?? 'Hardware Scanner')}',
          ),
          backgroundColor: Color(0xFF356033),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String scanModeText = AppLocalizations.of(context)?.notSet ?? 'Not set';
    if (_useCamera != null) {
      scanModeText = _useCamera!
          ? (AppLocalizations.of(context)?.cameraScanner ?? 'Camera Scanner')
          : (AppLocalizations.of(context)?.hardwareScanner ??
              'Hardware Scanner');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.parametrePage ?? 'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Scan Mode Section
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF356033).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Color(0xFF356033),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.scanMode ??
                                  'Scan Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              scanModeText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF356033), Color(0xFF2D5129)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: _selectScanMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.change ?? 'Change',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Language Section
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF356033).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Color(0xFF356033),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.language ??
                                  'Language',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _language ??
                                  (AppLocalizations.of(context)?.notSet ??
                                      'Not set'),
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            gradient: _language == "fr"
                                ? LinearGradient(colors: [
                                    Color(0xFF356033),
                                    Color(0xFF2D5129)
                                  ])
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: _language != "fr"
                                ? Border.all(color: Color(0xFF356033), width: 1)
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _setLanguage("fr"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _language == "fr"
                                  ? Colors.transparent
                                  : Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Français",
                              style: TextStyle(
                                color: _language == "fr"
                                    ? Colors.white
                                    : Color(0xFF356033),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: _language == "en"
                                ? LinearGradient(colors: [
                                    Color(0xFF356033),
                                    Color(0xFF2D5129)
                                  ])
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: _language != "en"
                                ? Border.all(color: Color(0xFF356033), width: 1)
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _setLanguage("en"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _language == "en"
                                  ? Colors.transparent
                                  : Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "English",
                              style: TextStyle(
                                color: _language == "en"
                                    ? Colors.white
                                    : Color(0xFF356033),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            gradient: _language == "ar"
                                ? LinearGradient(colors: [
                                    Color(0xFF356033),
                                    Color(0xFF2D5129)
                                  ])
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: _language != "ar"
                                ? Border.all(color: Color(0xFF356033), width: 1)
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _setLanguage("ar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _language == "ar"
                                  ? Colors.transparent
                                  : Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "العربية",
                              style: TextStyle(
                                color: _language == "ar"
                                    ? Colors.white
                                    : Color(0xFF356033),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
