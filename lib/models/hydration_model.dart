class HydrationModel {
  final String id;
  final String description;
  final int amount;
  final String type;
  final DateTime date;

  HydrationModel({
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.id = '',
  });

  factory HydrationModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    return HydrationModel(
      description: properties['Descripción']['title'][0]['plain_text'],
      amount: properties['Cantidad de Agua Consumida (ml)']['number'],
      type: properties['Tipo de Bebida']['select']['name'],
      date: DateTime.parse(properties['Fecha de Registro']['date']['start']),
      id: json['id'],
    );
  }
}