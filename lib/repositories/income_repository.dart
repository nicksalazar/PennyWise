import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nick_ai/models/category_model.dart';
import 'package:nick_ai/models/income_model.dart';
import 'package:http/http.dart' as http;
import 'package:nick_ai/models/reception_method_model.dart';
import 'package:nick_ai/repositories/interfaces/i_income_repository.dart';

class IncomeRepository implements IIncomeRepository {
  static const String _baseUrl = "https://api.notion.com/v1/";
  final http.Client _client;

  IncomeRepository({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  @override
  Future<void> archiveItem(String id, {bool archive = true}) async {
    final url = '${_baseUrl}pages/$id';
    final response = await _client.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Content-Type': 'application/json',
        'Notion-Version': '2022-06-28',
      },
      body: jsonEncode({
        'archived': archive, // Set archived to true to archive the page
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to archive item in Notion');
    } else {
      print("Item archived successfully");
    }
  }

  @override
  Future<IncomeModel> insertItem(IncomeModel item) async {
    final url = '${_baseUrl}pages';

    final response = await _client.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'parent': {'database_id': dotenv.env['NOTION_DATABASE_INCOME_ID']},
        'properties': {
          'Descripción': {
            'title': [
              {
                'text': {
                  'content': item.descripcion,
                },
              },
            ],
          },
          'Monto': {
            'number': item.monto,
          },
          'Fecha': {
            'date': {
              'start': item.fecha.toIso8601String(),
            },
          },
          'Categoría': {
            'select': {
              'name': item.categoria.name,
            },
          },
          'Método de Recepción': {
            'select': {
              'name': item.receptionMethodModel.name,
            },
          },
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to insert item into Notion');
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return IncomeModel.fromMap(data);
    }
  }

  @override
  Future<List<ReceptionMethodModel>> getReceptionsPayment() async {
    try {
      final url =
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_INCOME_ID']}';
      final response = await _client.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final properties = data['properties'] as Map<String, dynamic>;
        final selectProperty =
            properties['Método de Recepción'] as Map<String, dynamic>;
        final options = selectProperty['select']['options'] as List;
        return options.map((e) => ReceptionMethodModel.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      final errorMessage = 'Failed to load payment methods: ${e.toString()}';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final url =
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_INCOME_ID']}';
      final response = await _client.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final properties = data['properties'] as Map<String, dynamic>;
        final selectProperty = properties['Categoría'] as Map<String, dynamic>;
        final options = selectProperty['select']['options'] as List;
        return options.map((e) => Category.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      final errorMessage = 'Failed to load categories: ${e.toString()}';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<List<IncomeModel>> getItems() async {
    try {
      final url =
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_INCOME_ID']}/query';
      final response = await _client.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${dotenv.env['NOTION_API_KEY']}',
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return (data['results'] as List)
            .map((e) => IncomeModel.fromMap(e))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      final errorMessage = 'Failed to load items: ${e.toString()}';
      throw Exception(errorMessage);
    }
  }
}
