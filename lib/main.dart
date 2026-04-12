import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/presentation/theme/app_theme.dart';
import 'core/routes/router.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  runApp(const DarshanApp());
}

class DarshanApp extends StatelessWidget {
  const DarshanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTheme = AppTheme();
    
    return MaterialApp.router(
      title: 'Darshan Video App',
      theme: appTheme.light(),
      darkTheme: appTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
