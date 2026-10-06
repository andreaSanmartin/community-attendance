class UserModel {
  UserModel({required this.id, required this.fullName, required this.username, required this.role, required this.isActive, required this.mustChangePassword});
  final String id;
  final String fullName;
  final String username;
  final String role;
  final bool isActive;
  final bool mustChangePassword;
  bool get isSuperAdmin => role == 'SUPER_ADMIN' || role == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        fullName: json['full_name'],
        username: json['username'],
        role: json['role'],
        isActive: json['is_active'] ?? true,
        mustChangePassword: json['must_change_password'] ?? false,
      );
}
