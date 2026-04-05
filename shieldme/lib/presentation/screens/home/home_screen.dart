import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/bottom_nav/shield_bottom_nav.dart';
import 'tabs/home_tab.dart';
import 'tabs/sms_tab.dart';
import 'tabs/scan_tab.dart';
import 'tabs/wallet_tab.dart';
import 'tabs/premium_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = const [
    HomeTab(),
    SmsTab(),
    ScanTab(),
    WalletTab(),
    PremiumTab(),
    ProfileTab(),
  ];

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final user = authProvider.currentUser;
    final userName = user?.fullName.split(' ')[0] ?? 'Utilisateur';

    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar
          _buildAppBar(isDark, userName, themeProvider),
          // Main Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
          ),
          // Bottom Navigation
          ShieldBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, String userName, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ShieldMe 🛡️',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                'Bonjour, $userName 👋',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.grayLight,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny,
                size: 16,
                color: AppTheme.grayLight,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => themeProvider.toggleTheme(),
                child: Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.35) : AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}