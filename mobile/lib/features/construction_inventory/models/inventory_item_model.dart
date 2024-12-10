class InventoryItemModel {
  final int id;
  final String name;
  final int purchased;
  final int remaining;
  final String metrics;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.purchased,
    required this.remaining,
    required this.metrics,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      name: json['name'],
      purchased: json['quantityMax'],
      remaining: json['quantityLeft'],
      metrics: json['metrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantityMax': purchased,
      'quantityLeft': remaining,
      'metrics': metrics,
    };
  }

  InventoryItemModel copyWith({
    int? id,
    String? name,
    int? purchased,
    int? remaining,
    String? metrics,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      purchased: purchased ?? this.purchased,
      remaining: remaining ?? this.remaining,
      metrics: metrics ?? this.metrics,
    );
  }
}
