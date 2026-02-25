import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  final String categoryName;

  const AddProductPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _image = "assets/icons/fruits.png"; // по умолчанию
  bool _isLoading = false;

  void _showSnackBar(String text) {
    FocusScope.of(context).unfocus(); // скрываем клавиатуру
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _saveProductToSupabase() async {
    final title = _titleController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (title.isEmpty || price <= 0) {
      _showSnackBar("Введите корректные название и цену");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Вставка данных в Supabase 2.x
      final inserted = await Supabase.instance.client
          .from('products') // имя таблицы в Supabase
          .insert({
            'title': title,
            'price': price,
            'image': _image,
            'category': widget.categoryName,
          })
          .select(); // select() вернёт вставленные данные

      _showSnackBar("Продукт добавлен!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Ошибка: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _tryShowSnackBar() {
    final title = _titleController.text.trim();
    final price = int.tryParse(_priceController.text.trim());
    if (title.isNotEmpty && price != null && price > 0) {
      _showSnackBar("Продукт готов к добавлению");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Добавить продукт")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Название"),
              autofocus: true,
              onEditingComplete: _tryShowSnackBar,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Цена"),
              keyboardType: TextInputType.number,
              onEditingComplete: _tryShowSnackBar,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProductToSupabase,
                    child: const Text("Сохранить в Supabase"),
                  ),
          ],
        ),
      ),
    );
  }
}