import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/core/utils/whatsapp.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  int _int(dynamic v) => (v is int) ? v : int.tryParse(v.toString()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();

    final items = session.cart;
    final total = items.fold<int>(0, (sum, it) => sum + _int(it['price']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупки'),
        actions: items.isEmpty
            ? null
            : [
                TextButton(
                  onPressed: () => context.read<AppSession>().clearCart(),
                  child: const Text('Очистить'),
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? const Center(
                child: Text(
                  'Корзина пуста',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final it = items[index];
                        final title = (it['title'] ?? '').toString();
                        final price = _int(it['price']);
                        final seller = (it['seller_phone'] ?? '').toString();

                        return Card(
                          child: ListTile(
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                              seller.isEmpty ? 'Продавец не указан' : seller,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$price тг',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context
                                      .read<AppSession>()
                                      .removeFromCartAt(index),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Итого: $total тг',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final groups = <String, List<Map<String, dynamic>>>{};
                          for (final it in items) {
                            final seller = (it['seller_phone'] ?? '').toString();
                            if (seller.trim().isEmpty) continue;
                            groups.putIfAbsent(seller, () => []).add(it);
                          }

                          if (groups.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Нет номера продавца для оформления'),
                              ),
                            );
                            return;
                          }

                          if (groups.length == 1) {
                            final seller = groups.keys.first;
                            final list = groups[seller]!;
                            final msg = _buildMessage(list);
                            try {
                              await openWhatsApp(phone: seller, text: msg);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка WhatsApp: $e')),
                              );
                            }
                            return;
                          }

                          if (!context.mounted) return;
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            builder: (ctx) => SafeArea(
                              child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(12),
                                children: [
                                  const Text(
                                    'Выберите продавца',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  ...groups.entries.map((e) {
                                    return ListTile(
                                      title: Text(e.key),
                                      subtitle: Text(
                                        '${e.value.length} товар(ов)',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        final msg = _buildMessage(e.value);
                                        try {
                                          await openWhatsApp(
                                            phone: e.key,
                                            text: msg,
                                          );
                                        } catch (err) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Ошибка WhatsApp: $err'),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('Оформить'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  String _buildMessage(List<Map<String, dynamic>> items) {
    final lines = <String>['Здравствуйте! Хочу купить:'];
    for (final it in items) {
      final title = (it['title'] ?? '').toString();
      final price = _int(it['price']);
      lines.add('- $title — $price тг');
    }
    return lines.join('\n');
  }
}

