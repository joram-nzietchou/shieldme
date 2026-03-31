import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'themes/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return MaterialApp(
            title: 'ShieldMe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: '/',
            routes: {
              '/': (context) => FutureBuilder<bool>(
                    future: authService.isLoggedIn(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.data == true) {
                        // Rediriger vers l'écran principal
                        return const Placeholder(); // À remplacer par HomeScreen
                      }
                      return const LoginScreen();
                    },
                  ),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/otp': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map;
                return OTPScreen(
                  phone: args['phone'],
                  fullName: args['fullName'],
                  referralCode: args['referralCode'],
                  isRegister: args['isRegister'] ?? false,
                );
              },
            },
          );
        },
      ),
    );
  }
}