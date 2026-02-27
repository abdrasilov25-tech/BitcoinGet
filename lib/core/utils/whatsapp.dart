import 'package:url_launcher/url_launcher.dart';

String _digitsOnly(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

Future<void> openWhatsApp({
  required String phone,
  String? text,
}) async {
  final digits = _digitsOnly(phone);
  if (digits.isEmpty) {
    throw Exception('Empty phone');
  }

  final query = (text == null || text.trim().isEmpty)
      ? ''
      : '?text=${Uri.encodeComponent(text)}';

  final uri = Uri.parse('https://wa.me/$digits$query');

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    throw Exception('Could not launch WhatsApp url');
  }
}

