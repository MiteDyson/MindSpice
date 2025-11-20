class CategoryModel {
  String id;
  String name;
  int colorValue; // store as Color.value

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id: j['id'] as String,
    name: j['name'] as String,
    colorValue: j['colorValue'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
  };
}
