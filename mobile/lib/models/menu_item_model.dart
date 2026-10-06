class MenuItemModel {
  const MenuItemModel({required this.key, required this.label, required this.icon});
  final String key;
  final String label;
  final String icon;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        key: json['key'] as String,
        label: json['label'] as String,
        icon: (json['icon'] ?? '') as String,
      );
}
