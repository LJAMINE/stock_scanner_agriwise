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
      )),
    );
  }

  Future<void> _selectScanMode() async {
    bool? useCamera = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            AppLocalizations.of(context)?.selectScanMode ?? 'Select scan mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title:
                  Text(AppLocalizations.of(context)?.useCamera ?? 'Use Camera'),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: Icon(Icons.scanner_outlined),
              title: Text(AppLocalizations.of(context)?.useHardwareScanner ??
                  'Use Hardware Scanner'),
              onTap: () => Navigator.pop(ctx, false),
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
        title: Text(AppLocalizations.of(context)?.parametrePage ?? 'Parametre'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)?.scanMode ?? 'Scan Mode'),
            subtitle: Text(scanModeText),
            trailing: ElevatedButton(
              onPressed: _selectScanMode,
              child: Text(AppLocalizations.of(context)?.change ?? 'Change'),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
            subtitle: Text(_language ??
                (AppLocalizations.of(context)?.notSet ?? 'Not set')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _setLanguage("fr"),
                child: Text("Français"),
              ),
              ElevatedButton(
                onPressed: () => _setLanguage("en"),
                child: Text("English"),
              ),
              ElevatedButton(
                onPressed: () => _setLanguage("ar"),
                child: Text("العربية"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
