import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bazar/core/state/app_session.dart';

class EntrancePage extends StatefulWidget {
  const EntrancePage({super.key});

  @override
  State<EntrancePage> createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final TextEditingController _phoneController = TextEditingController();
  bool _isSeller = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Запускаем анимацию сразу
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continueAsBuyer() async {
    if (!mounted) return;
    context.read<AppSession>().setBuyer();
    Navigator.pushReplacementNamed(context, '/main');
  }

  Future<void> _continueAsSeller() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер WhatsApp продавца')),
      );
      return;
    }
    if (!mounted) return;
    context.read<AppSession>().setSeller(phone: phone);
    Navigator.pushReplacementNamed(context, '/main');
  }

  Widget _modeCard({
    required bool selected,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFDEE2E6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary.withAlpha(18)
                    : const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/icons/bazar.png',
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bazar',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Купи. Продай. Быстро.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Выберите режим',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        _modeCard(
                          selected: !_isSeller,
                          title: 'Покупатель',
                          subtitle: 'Смотреть объявления и писать продавцу',
                          icon: Icons.search_outlined,
                          onTap: () => setState(() => _isSeller = false),
                        ),
                        const SizedBox(height: 10),
                        _modeCard(
                          selected: _isSeller,
                          title: 'Продавец',
                          subtitle: 'Размещать товары и принимать заявки',
                          icon: Icons.storefront_outlined,
                          onTap: () => setState(() => _isSeller = true),
                        ),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _isSeller
                              ? Column(
                                  key: const ValueKey('seller'),
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'WhatsApp номер',
                                        hintText: 'Напр. +7 777 123 45 67',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _continueAsSeller,
                                      child: const Text('Продолжить'),
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('buyer'),
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _continueAsBuyer,
                                      child: const Text('Перейти к покупкам'),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  'Продолжая, вы соглашаетесь с правилами сервиса Bazar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
