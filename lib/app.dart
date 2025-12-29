import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:budget_manager/screens/add_transaction_screen.dart';
import 'package:budget_manager/screens/home_screen.dart';
import 'package:budget_manager/screens/analysis_screen.dart';
import 'package:budget_manager/screens/transactions_screen.dart';
import 'package:budget_manager/screens/dashboard_screen.dart';
import 'package:budget_manager/screens/profile_screen.dart';

import 'package:budget_manager/theme/auth_palette.dart';
import 'package:budget_manager/widgets/auth/auth_background.dart';
import 'package:budget_manager/widgets/ai_chat_dialog.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalysisScreen(),
    TransactionsScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _openAIChat() {
    showDialog(
      context: context,
      builder: (_) => const AIChatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define gradients based on selected screen
    LinearGradient getGradient() {
      switch (_selectedIndex) {
        case 0: // Home
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AuthPalette.tangerine, AuthPalette.mint],
          );
        case 1: // Analysis
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
          );
        case 2: // Transactions
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
          );
        case 3: // Dashboard
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
          );
        default: // Profile
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
          );
      }
    }

    return AuthBackground(
      gradient: getGradient(),
      safeAreaTop: false,
      safeAreaBottom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _GlassNavigationBar(
          selectedIndex: _selectedIndex,
          onSelected: _onItemTapped,
        ),
        floatingActionButton: () {
          // ✅ Analyse tab -> AI button
          if (_selectedIndex == 1) {
            return FloatingActionButton(
              onPressed: _openAIChat,
              backgroundColor: AuthPalette.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.smart_toy, size: 24),
              heroTag: "ai_fab",
            );
          }

          // ✅ Transactions tab -> add transaction
          if (_selectedIndex == 2) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: AuthPalette.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add, size: 26),
              heroTag: "add_transaction_fab",
            );
          }

          return null;
        }(),
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _GlassNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  static Color _a(Color c, double o) => c.withAlpha((o * 255).round());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _a(AuthPalette.lavender, 0.22),
                    _a(AuthPalette.peach, 0.18),
                    _a(AuthPalette.lemon, 0.16),
                    _a(AuthPalette.mint, 0.14),
                  ],
                ),
                border: Border.all(color: _a(Colors.white, 0.70)),
                boxShadow: [
                  BoxShadow(
                    color: _a(Colors.black, 0.12),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 72,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelected,
                indicatorColor: _a(AuthPalette.lavender, 0.35),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Accueil',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: 'Analyse',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.swap_horiz_outlined),
                    selectedIcon: Icon(Icons.swap_horiz_rounded),
                    label: 'Transactions',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
