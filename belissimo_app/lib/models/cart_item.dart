class CartItem {
  final String id;
  final String name;
  final int price; // Unit price including size offset
  final String image;
  final String size;
  final List<String> extras;
  final String extrasKey;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.size,
    required this.extras,
    required this.extrasKey,
    this.quantity = 1,
  });

  int get total => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image': image,
    'size': size,
    'extras': extras,
    'extrasKey': extrasKey,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
      size: json['size'],
      extras: List<String>.from(json['extras'] ?? []),
      extrasKey: json['extrasKey'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
