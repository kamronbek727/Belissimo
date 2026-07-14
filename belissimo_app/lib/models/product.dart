class ProductSizeOption {
  final String value; // e.g. "18 sm"
  final String desc;  // e.g. "6-8 kishiga"
  final int priceOffset; // e.g. 0, -40000, 60000

  const ProductSizeOption({
    required this.value,
    required this.desc,
    required this.priceOffset,
  });

  Map<String, dynamic> toJson() => {
    'value': value,
    'desc': desc,
    'priceOffset': priceOffset,
  };

  factory ProductSizeOption.fromJson(Map<String, dynamic> json) {
    return ProductSizeOption(
      value: json['value'],
      desc: json['desc'],
      priceOffset: json['priceOffset'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category; // e.g. "tortlar", "fastfood", "shirinliklar", "ichimliklar"
  final String description;
  final int basePrice;
  final String imageAsset;
  final double rating;
  final int reviewCount;
  final List<ProductSizeOption> sizes;
  final bool hasDiscount;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.basePrice,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
    this.sizes = const [],
    this.hasDiscount = false,
  });

  // Centralized inventory of Belissimo products matching index.html, cake.html, burger.html, etc.
  static List<Product> get defaultInventory => [
    const Product(
      id: 'malinali-tort',
      name: 'Malinali shokoladli tort',
      category: 'tortlar',
      description: 'Nozik shokoladli biskvit, malinali muuz va shokolad ganash bilan bezatilgan shokoladli tort.',
      basePrice: 129000,
      imageAsset: 'assets/images/tort.png',
      rating: 4.8,
      reviewCount: 126,
      hasDiscount: true,
      sizes: [
        ProductSizeOption(value: '12 sm', desc: '4-6 kishiga', priceOffset: -40000),
        ProductSizeOption(value: '18 sm', desc: '6-8 kishiga', priceOffset: 0),
        ProductSizeOption(value: '24 sm', desc: '10-12 kishiga', priceOffset: 60000),
      ],
    ),
    const Product(
      id: 'classic-burger',
      name: 'Classic Burger',
      category: 'fastfood',
      description: 'Mol go\'shti kotleti, cheddar pishlog\'i, tomat, marul va maxsus sous.',
      basePrice: 45000,
      imageAsset: 'assets/images/burger.png',
      rating: 4.6,
      reviewCount: 91,
      hasDiscount: false,
      sizes: [], // No sizes
    ),
    const Product(
      id: 'lavash',
      name: 'Katta Lavash',
      category: 'fastfood',
      description: 'Issiq va mazali lavash, mol go\'shti, erigan pishloq, bodring, pomidor va maxsus sous bilan tayyorlangan.',
      basePrice: 35000,
      imageAsset: 'assets/images/lavash.png',
      rating: 4.7,
      reviewCount: 78,
      hasDiscount: true,
      sizes: [
        ProductSizeOption(value: 'Mini', desc: 'Yengil tamaddi', priceOffset: -8000),
        ProductSizeOption(value: 'Standard', desc: 'Klassik o\'lcham', priceOffset: 0),
        ProductSizeOption(value: 'Katta', desc: 'Haqiqiy ochlar uchun', priceOffset: 10000),
      ],
    ),
    const Product(
      id: 'cake',
      name: 'Qizil baxmal cake',
      category: 'shirinliklar',
      description: 'Yumshoq va shirin "Qizil baxmal" keks, qaymoqli krem pishloq va malinali murabbo bilan mukammal birlashma.',
      basePrice: 38000,
      imageAsset: 'assets/images/cake.png',
      rating: 4.9,
      reviewCount: 112,
      hasDiscount: true,
      sizes: [
        ProductSizeOption(value: 'Mini', desc: 'Tez tamaddi', priceOffset: -10000),
        ProductSizeOption(value: 'Standard', desc: 'O\'rtacha o\'lcham', priceOffset: 0),
        ProductSizeOption(value: 'Katta', desc: 'Oila davrasida', priceOffset: 12000),
      ],
    ),
  ];
}
