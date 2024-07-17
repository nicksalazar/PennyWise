import 'package:nick_ai/models/category_model.dart';
import 'package:nick_ai/models/reception_method_model.dart';

class IncomeModel {
  final String id;
  final String descripcion;
  final DateTime fecha;
  final Category categoria;
  final double monto;
  final ReceptionMethodModel receptionMethodModel;

  IncomeModel({required this.descripcion,required this.fecha,required this.categoria,required this.monto,required this.receptionMethodModel, required this.id});

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>? ?? {};
  
    final dateStr = properties["Fecha"]?["date"]?["start"]??'';
    final descripcion = properties["Descripción"]?["title"]?[0]?["text"]?["content"] as String? ?? '';
    final montoStr = properties["Monto"]?["number"]?.toDouble() ?? 0.0;
    final id = map["id"] as String? ?? '';
    final categoria_ = Category.fromMap(properties["Categoría"]?["select"] ?? {});
    final receptionMethod_ = ReceptionMethodModel.fromMap(properties["Método de Recepción"]?["select"] ?? {});
    final categoria = Category(id: categoria_.id, name: categoria_.name, color: categoria_.color);

    final receptionMethod = ReceptionMethodModel(id: receptionMethod_.id, name: receptionMethod_.name, color: receptionMethod_.color);
    return IncomeModel(
      descripcion: descripcion,
      fecha: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      categoria: categoria,
      receptionMethodModel: receptionMethod,
      monto: montoStr,
      id: id
    );
  }
}