class YouthModel {
  YouthModel({required this.id, required this.fullName, required this.phone, required this.tribeId, this.projectId, required this.qrToken, required this.isActive});
  final String id;
  final String fullName;
  final String phone;
  final String tribeId;
  final String? projectId;
  final String qrToken;
  final bool isActive;

  factory YouthModel.fromJson(Map<String, dynamic> json) => YouthModel(
        id: json['id'].toString(),
        fullName: json['full_name'] as String,
        phone: json['phone'] as String,
        tribeId: json['tribe_id'].toString(),
        projectId: json['project_id']?.toString(),
        qrToken: json['qr_token'].toString(),
        isActive: json['is_active'] as bool? ?? true,
      );
}
