enum UserRole {
  customer('Customer'),
  rider('Rider');

  final String displayName;
  const UserRole(this.displayName);

  static UserRole fromString(String? val) {
    if (val == null) return UserRole.customer;
    final normalized = val.trim().toLowerCase();
    if (normalized == 'rider' || normalized == 'driver') {
      return UserRole.rider;
    }
    return UserRole.customer;
  }
}

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final String? token;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get isRider => role == UserRole.rider;
  bool get isCustomer => role == UserRole.customer;

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    String? token,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'token': token,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 101,
      firstName: json['firstName'] as String? ?? 'User',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      token: json['token'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
