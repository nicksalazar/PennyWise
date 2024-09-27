import 'package:flutter/material.dart';
import 'package:pennywise/data/currency_data.dart';
import 'package:pennywise/providers/language_provider.dart';
import 'package:pennywise/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(
          l10n.myDrawerSettings,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.languageSettings),
            trailing: DropdownButton<String>(
              value: languageProvider.currentLocale.languageCode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  languageProvider.changeLanguage(Locale(newValue));
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Español'),
                ),
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português'),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.currencySettings),
            trailing: DropdownButton<String>(
              value: languageProvider
                  .selectedCurrency, // Default value, you can change this to a variable
              onChanged: (String? newValue) {
                if (newValue != null) {
                  languageProvider.changeCurrency(newValue);
                }
              },
              items: currencies.map<DropdownMenuItem<String>>((currency) {
                return DropdownMenuItem<String>(
                  value: currency['code'],
                  child: Text(
                    '${currency['name'][languageProvider.currentLocale.languageCode]} (${currency['symbol']})',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
