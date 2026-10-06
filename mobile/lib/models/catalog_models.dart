class TribeModel {
  TribeModel({required this.id, required this.name, this.description, required this.isActive});
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  factory TribeModel.fromJson(Map<String, dynamic> json) => TribeModel(id: json['id'].toString(), name: json['name'], description: json['description'], isActive: json['is_active'] ?? true);
}

class ProjectModel {
  ProjectModel({required this.id, required this.name, this.tribeId, this.description, required this.isActive});
  final String id;
  final String name;
  final String? tribeId;
  final String? description;
  final bool isActive;
  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(id: json['id'].toString(), name: json['name'], tribeId: json['tribe_id']?.toString(), description: json['description'], isActive: json['is_active'] ?? true);
}
