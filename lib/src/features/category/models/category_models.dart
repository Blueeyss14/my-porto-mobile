class CategoryModels {
  final int id;
  final String name;

  CategoryModels({required this.id, required this.name});

  factory CategoryModels.fromJson(Map<String, dynamic> json) {
    return CategoryModels(id: json['id'] ?? 0, name: json['name']);
  }
}
