import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:habit_harmony/models/hydration_model.dart';
import 'package:habit_harmony/repositories/interfaces/i_hydratation_repository.dart';

class HydrationRepository implements IHydratationRepository {
  static const String _baseUrl = "https://api.notion.com/v1/";
  final http.Client _client;

  HydrationRepository({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<HydrationModel>> fetchDrinkEntries(DateTime date) async {
    final response = await _client.post(
      Uri.parse(
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_HYDRATATION_ID']}/query'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "filter": {
          "property": "Fecha de Registro",
          "date": {"equals": date.toIso8601String().split('T')[0]}
        }
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => HydrationModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch drink entries');
    }
  }

  @override
  Future<void> addDrinkEntry(HydrationModel entry) async {
    // create an API call to add a new entry to Notion
    final url = '${_baseUrl}pages';
    final response = await _client.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'parent': {'database_id': dotenv.env['NOTION_DATABASE_HYDRATATION_ID']},
        'properties': {
          'Descripción': {
            'title': [
              {
                'text': {'content': entry.description}
              }
            ]
          },
          'Fecha de Registro': {
            'date': {'start': entry.date.toIso8601String()}
          },
          'Tipo de Bebida': {
            'select': {'name': entry.type}
          },
          'Cantidad de Agua Consumida (ml)': {'number': entry.amount},
        },
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add drink entry');
    }
  }

  //fetch entries by range
  @override
  Future<List<HydrationModel>> fetchDrinkEntriesByRange(
      DateTime startDate, DateTime endDate) async {
    final response = await _client.post(
      Uri.parse(
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_HYDRATATION_ID']}/query'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "filter": {
          "and": [
            {
              "property": "Fecha de Registro",
              "date": {
                "on_or_after": startDate.toIso8601String().split('T')[0],
              }
            },
            {
              "property": "Fecha de Registro",
              "date": {
                "on_or_before": endDate.toIso8601String().split('T')[0],
              }
            }
          ]
        }
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => HydrationModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch drink entries');
    }
  }

  @override
  Future<void> deleteDrinkEntry(String id) async {
    final url = '${_baseUrl}pages/$id';
    final response = await _client.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'archived': true, // Set archived to true to archive the page
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete drink entry');
    }
  }

  void dispose() {
    _client.close();
  }
}
