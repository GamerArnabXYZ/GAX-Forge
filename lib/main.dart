import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/providers/forge_provider.dart';
import 'ui/theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF5F6FA),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const GAXForgeApp());
}

class GAXForgeApp extends StatelessWidget {
  const GAXForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgeProvider(),
      child: MaterialApp(
        title: 'GAX Forge',
        debugShowCheckedModeBanner: false,
        theme: ForgeTheme.themeData,
        home: const DashboardScreen(),
      ),
    );
  }
}
