import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pennywise/providers/language_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
      ),
      body: ListView(
        children: [
          RadioListTile<Locale>(
            title: Text('English'),
            value: Locale('en'),
            groupValue: languageProvider.currentLocale,
            onChanged: (Locale? value) {
              if (value != null) languageProvider.changeLanguage(value);
            },
          ),
          RadioListTile<Locale>(
            title: Text('Español'),
            value: Locale('es'),
            groupValue: languageProvider.currentLocale,
            onChanged: (Locale? value) {
              if (value != null) languageProvider.changeLanguage(value);
            },
          ),
          //portuguese
          RadioListTile<Locale>(
            title: Text('Português'),
            value: Locale('pt'),
            groupValue: languageProvider.currentLocale,
            onChanged: (Locale? value) {
              if (value != null) languageProvider.changeLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}