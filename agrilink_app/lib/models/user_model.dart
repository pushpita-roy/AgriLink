enum UserRole { buyer, farmer, admin }

UserRole _parseRole(String role) {
  switch (role) {
    case 'farmer':
      return UserRole.farmer;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.buyer;
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final String address;
  final String district;
  final String? division;
  final String? farmName;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.role,
    this.phone = '',
    this.address = '',
    this.district = '',
    this.division,
    this.farmName,
    this.isVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? json['username'] ?? 'User',
      email: json['email'] ?? '',
      role: _parseRole(json['role'] ?? 'buyer'),
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
      division: (json['division'] ?? json['location'] ?? json['district'] ?? '').toString(),
      farmName: json['farm_name'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? phone,
    String? address,
    String? district,
    String? division,
    String? farmName,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      district: district ?? this.district,
      division: division ?? this.division,
      farmName: farmName ?? this.farmName,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
