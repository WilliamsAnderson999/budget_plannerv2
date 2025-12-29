import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:budget_manager/screens/auth_wrapper.dart';
import 'package:budget_manager/services/theme_service.dart';
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/services/firestore_service.dart';
import 'package:budget_manager/services/notification_service.dart';

const bool kUseEmulators =
    bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  if (kDebugMode && kUseEmulators) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    debugPrint('Using Firebase EMULATORS (localhost:9099 / localhost:8080)');
  } else {
    debugPrint('Using Firebase CLOUD (production)');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: const BudgetManagerApp(),
    ),
  );
}

class BudgetManagerApp extends StatelessWidget {
  const BudgetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Budget Manager',
          theme: themeService.currentTheme,
          home: const AuthWrapper(),
        );
      },
    );
  }
}
