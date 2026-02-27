class Product {
  final String id;
  final String title;
  final int price;
  final String description;
  final String category;
  final String mediaUrl;
  final String mediaType; // "image" | "video"
  final String sellerPhone;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.mediaUrl,
    required this.mediaType,
    required this.sellerPhone,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      price: (map['price'] is int)
          ? map['price'] as int
          : int.tryParse((map['price'] ?? '0').toString()) ?? 0,
      description: (map['description'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      mediaUrl: (map['media_url'] ?? '').toString(),
      mediaType: (map['media_type'] ?? 'image').toString(),
      sellerPhone: (map['seller_phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'seller_phone': sellerPhone,
    };
  }
}

