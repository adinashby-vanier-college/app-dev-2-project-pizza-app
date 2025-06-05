class Pizza {
  final String name;
  final String description;
  final String picture;
  final int price;
  final String pizzaId;
  final int calories;
  final int carbs;
  final int fat;
  final int proteins;

  Pizza({
    required this.name,
    required this.description,
    required this.picture,
    required this.price,
    required this.pizzaId,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.proteins,
  });

  factory Pizza.fromJson(Map<String, dynamic> json, String id) {
    return Pizza(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      picture: json['picture'] ?? '',
      price: json['price'] ?? 0,
      pizzaId: id ?? '',
      calories: json['macros']['calories'] ?? 0,
      carbs: json['macros']['carbs'] ?? 0,
      fat: json['macros']['fat'] ?? 0,
      proteins: json['macros']['proteins'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'picture': picture,
      'price': price,
      'pizzaId': pizzaId,
      'macros': {
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'proteins': proteins,
      },
    };
  }
}
