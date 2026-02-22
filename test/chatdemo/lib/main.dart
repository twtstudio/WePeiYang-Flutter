import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/chat_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: '私信系统',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1ABC9C),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF1ABC9C),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.light,
        home: const LoginScreen(),
      ),
    );
  }
}
