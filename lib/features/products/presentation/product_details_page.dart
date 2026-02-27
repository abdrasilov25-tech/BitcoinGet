import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bazar/core/utils/whatsapp.dart';
import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/products/product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  Widget _media(BuildContext context) {
    final url = product.mediaUrl.trim();
    final isImage = product.mediaType == 'image';
    final isVideo = product.mediaType == 'video';

    if (url.isEmpty) {
      return Image.asset(
        'assets/icons/fruits.png',
        fit: BoxFit.cover,
      );
    }

    if (isImage) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/icons/fruits.png',
          fit: BoxFit.cover,
        ),
      );
    }

    if (isVideo) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 72),
        ),
      );
    }

    return Image.asset(
      'assets/icons/fruits.png',
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazar'),
        actions: [
          IconButton(
            tooltip: 'В избранное',
            onPressed: () => context.read<AppSession>().toggleFavorite(product.id),
            icon: Icon(
              session.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
              color: session.isFavorite(product.id) ? Colors.red : Colors.black54,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: _media(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.price} тг',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Описание',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description.trim().isEmpty
                        ? 'Описание не указано'
                        : product.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black87, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: session.isSeller
                        ? null
                        : () {
                            if (product.id.isEmpty ||
                                product.sellerPhone.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Нельзя добавить в корзину')),
                              );
                              return;
                            }
                            context.read<AppSession>().addToCart(
                                  productId: product.id,
                                  title: product.title,
                                  price: product.price,
                                  sellerPhone: product.sellerPhone,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Добавлено в покупки')),
                            );
                          },
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('В покупки'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: product.sellerPhone.trim().isEmpty
                        ? null
                        : () async {
                            try {
                              await openWhatsApp(
                                phone: product.sellerPhone,
                                text:
                                    'Здравствуйте! Интересует товар: ${product.title} (${product.price} тг)',
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Не удалось открыть WhatsApp: $e')),
                              );
                            }
                          },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

