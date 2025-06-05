class CartItem {
  final String pizzaId;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  CartItem({
    required this.pizzaId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      pizzaId: data['pizzaId'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pizzaId': pizzaId,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
    };
  }
}
