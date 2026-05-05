class Product {
  final String id;
  final String farmerId;
  final String farmerName;
  final String name;
  final String category;
  final String description;
  final String unitType; // kg, liter, dozen, crate, bundle, piece
  final double pricePerUnit;
  final double stockQty;
  final String location;
  final DateTime? harvestDate;
  final String imagePath;
  final double rating;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.farmerId,
    this.farmerName = '',
    required this.name,
    this.category = '',
    this.description = '',
    this.unitType = 'kg',
    required this.pricePerUnit,
    this.stockQty = 0,
    this.location = '',
    this.harvestDate,
    this.imagePath = '',
    this.rating = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      farmerId: (json['farmer_id'] ?? '').toString(),
      farmerName: json['farmer_name'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      unitType: json['unit_type'] ?? 'kg',
      pricePerUnit: double.tryParse(json['price_per_unit'].toString()) ?? 0,
      stockQty: double.tryParse(json['stock_qty'].toString()) ?? 0,
      location: json['location'] ?? '',
      harvestDate: json['harvest_date'] != null
          ? DateTime.tryParse(json['harvest_date'].toString())
          : null,
      imagePath: json['image_path'] ?? json['image_url'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'unit_type': unitType,
      'price_per_unit': pricePerUnit.toString(),
      'stock_qty': stockQty.toString(),
      'location': location,
      'harvest_date': harvestDate?.toIso8601String().split('T').first,
      'image_url': imagePath,
      'rating': rating.toString(),
    };
  }

  Product copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? name,
    String? category,
    String? description,
    String? unitType,
    double? pricePerUnit,
    double? stockQty,
    String? location,
    DateTime? harvestDate,
    String? imagePath,
    double? rating,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      unitType: unitType ?? this.unitType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      stockQty: stockQty ?? this.stockQty,
      location: location ?? this.location,
      harvestDate: harvestDate ?? this.harvestDate,
      imagePath: imagePath ?? this.imagePath,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
