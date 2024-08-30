import 'package:flutter/material.dart';
import 'package:pennywise/data/currency_data.dart';
import 'package:pennywise/l10n/l10n.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onLanguageChanged;
  final Function(String) onCurrencyChanged;

  const SettingsScreen({
    Key? key,
    required this.onLanguageChanged,
    required this.onCurrencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.translate('settings'),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(L10n.translate('language')),
            trailing: DropdownButton<String>(
              value: L10n.currentLocale,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onLanguageChanged(newValue);
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
              ],
            ),
          ),
          ListTile(
            title: Text(L10n.translate('currency')),
            trailing: DropdownButton<String>(
              value: L10n.currentCurrency,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onCurrencyChanged(newValue);
                }
              },
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency['code'],
                  child: Text('${currency['name']} (${currency['symbol']})'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
