class InventoryItemModel {
  final int id;
  final String name;
  final double purchased; // Renamed from quantityMax
  final String metrics;
  final double remaining; // Renamed from quantityLeft
  final int addressId;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.purchased, // Updated name
    required this.metrics,
    required this.remaining, // Updated name
    required this.addressId,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      purchased: (json['quantityMax'] as num?)?.toDouble() ?? 0.0, // Renamed field
      metrics: json['metrics'] as String? ?? '', // Handle null
      remaining: (json['quantityLeft'] as num?)?.toDouble() ?? 0.0, // Renamed field
      addressId: json['addressId'] as int? ?? 0, // Handle null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'purchased': purchased, // Updated name
      'metrics': metrics,
      'remaining': remaining, // Updated name
      'addressId': addressId,
    };
  }

  InventoryItemModel copyWith({
    int? id,
    String? name,
    double? purchased, // Updated name
    String? metrics,
    double? remaining, // Updated name
    int? addressId,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      purchased: purchased ?? this.purchased, // Updated name
      metrics: metrics ?? this.metrics,
      remaining: remaining ?? this.remaining, // Updated name
      addressId: addressId ?? this.addressId,
    );
  }
}
