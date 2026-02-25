import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Bloc и UseCase
import 'features/home/usecases/get_market_categories.dart';
import 'features/home/data/repositories/market_repository_impl.dart';
import 'features/home/presentation/cubit/market_cubit.dart';
import 'core/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Загружаем .env
  try {
   await dotenv.load(fileName: "/Users/beksultanbekmurzaev/flutter.project/bazar/.env"); // .env должен быть в корне проекта рядом с pubspec.yaml
  } catch (e) {
    debugPrint("Не удалось загрузить .env: $e");
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  // 🔹 Проверка ключей
  if (supabaseUrl == null || supabaseKey == null) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Ошибка: .env не найден или ключи пустые',
              style: const TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // 🔹 Инициализация Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // 🔹 Репозиторий и UseCase для Bloc
  final repository = MarketRepositoryImpl();
  final useCase = GetMarketCategories(repository);

  runApp(MyApp(useCase: useCase));
}

class MyApp extends StatelessWidget {
  final GetMarketCategories useCase;

  const MyApp({super.key, required this.useCase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketCubit(useCase),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        onGenerateRoute: AppRouter.generateRoute,
        // Для проверки Supabase можно временно поставить:
        // home: Scaffold(body: Center(child: Text('Supabase ready!'))),
        initialRoute: '/',
      ),
    );
  }
}
