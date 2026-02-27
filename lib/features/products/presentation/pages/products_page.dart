import 'package:flutter/material.dart';
import 'package:bazar/features/products/presentation/all_products_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Список категорий
  static const List<Map<String, String>> categories = [
    {"title": "Фрукты", "image": "assets/icons/fruits.png"},
    {"title": "Овощи", "image": "assets/icons/vegetables.png"},
    {"title": "Молочные", "image": "assets/icons/dairy.png"},
    {"title": "Напитки", "image": "assets/icons/drinks.png"},
    {"title": "Сладости", "image": "assets/icons/sweets.png"},
    {"title": "Мясо", "image": "assets/icons/meat.png"},
    {"title": "Рыба", "image": "assets/icons/fish.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bazar • Продукты"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllProductsPage(
                    categoryName: category["title"]!,
                  ),
                ),
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDEE2E6)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      category["image"]!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category["title"]!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}