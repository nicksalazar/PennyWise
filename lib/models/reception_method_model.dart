class ReceptionMethodModel {
  final String id;
  final String name;
  final String color;

  ReceptionMethodModel({required this.id, required this.name, required this.color});

  factory ReceptionMethodModel.fromMap(Map<String, dynamic> map) {
    return ReceptionMethodModel(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }
}