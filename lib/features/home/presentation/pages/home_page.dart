import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bazar/features/home/presentation/cubit/market_cubit.dart';

import 'package:bazar/core/state/app_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<MarketCubit>().loadCategories();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bazar"),
        actions: [
          if (session.isSeller)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Продавец',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Покупатель',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MarketCubit, List<MarketCategory>>(
          builder: (context, categories) {
            final filtered = categories.where((category) {
              final title = category.title.toLowerCase();
              return title.contains(_searchQuery);
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Поиск в Bazar',
                            prefixIcon: Icon(Icons.search_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primary.withAlpha(16),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(28),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Найдите товары рядом и пишите продавцу в WhatsApp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Категории',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                filtered.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('Категории не найдены')),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final c = filtered[i];
                              return InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => Navigator.pushNamed(context, c.route),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFDEE2E6),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.asset(
                                            c.imagePath,
                                            width: 46,
                                            height: 46,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            c.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}