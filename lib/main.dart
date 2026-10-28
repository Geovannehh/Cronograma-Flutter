import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/schedule_controller.dart';
import 'core/app_theme.dart';
import 'data/schedule_repository.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CronogramaApp());
}

class CronogramaApp extends StatefulWidget {
  const CronogramaApp({super.key});

  @override
  State<CronogramaApp> createState() => _CronogramaAppState();
}

class _CronogramaAppState extends State<CronogramaApp> {
  late final ScheduleController controller = ScheduleController(ScheduleRepository());

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flow | Meu cronograma',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: HomeScreen(controller: controller),
  );
}
