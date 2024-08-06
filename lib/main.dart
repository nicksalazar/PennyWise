import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/providers/Income_provider.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/providers/expense_provider.dart';
import 'package:habit_harmony/providers/hydration_provider.dart';
import 'package:habit_harmony/providers/loading_provider.dart';
import 'package:habit_harmony/providers/transaction_provider.dart';
import 'package:habit_harmony/providers/transfer_provider.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/hydration_repository.dart';
import 'package:habit_harmony/repositories/transfer_repository.dart';
import 'package:habit_harmony/screens/accounts/account_new_screen.dart';
import 'package:habit_harmony/screens/accounts/account_new_transfer_screen.dart';
import 'package:habit_harmony/screens/accounts/account_screen.dart';
import 'package:habit_harmony/screens/accounts/account_transfer_history_screen.dart';
import 'package:habit_harmony/screens/auth_wrapper.dart';
import 'package:habit_harmony/screens/categories/categories_screen.dart';
import 'package:habit_harmony/screens/home/home_screen.dart';
import 'package:habit_harmony/screens/login_screen.dart';
import 'package:habit_harmony/screens/categories/categories_new_screen.dart';
import 'package:habit_harmony/screens/register_screen.dart';
import 'package:habit_harmony/screens/splash_screen.dart';
import 'package:habit_harmony/themes/app_theme.dart';
import 'package:habit_harmony/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize notification plugin
  await initNotifications();

  // Set up water reminders
  await setupWaterReminders();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoadingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HydrationProvider(
            HydrationRepository()
              ..fetchDrinkEntries(
                DateTime.now(),
              ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()
            ..fetchCategories()
            ..fetchExpenses()
            ..fetchAccounts(),
        ),
        ChangeNotifierProvider(
            create: (_) => IncomeProvider()
              ..fetchCategories()
              ..fetchIncomes()),
        ChangeNotifierProvider(
          create: (context) => AccountProvider(
            AccountsRepository(),
            TransferRepository(),
            Provider.of<LoadingProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TransferProvider(
            TransferRepository(),
            Provider.of<LoadingProvider>(context, listen: false),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> initNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> setupWaterReminders() async {
  tz.initializeTimeZones();

  for (int i = 0; i < 6; i++) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      i,
      'Time to hydrate!',
      'Don\'t forget to drink some water.',
      _nextInstanceOfOneHour(i),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminders',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

tz.TZDateTime _nextInstanceOfOneHour(int hourOffset) {
  final now = tz.TZDateTime.now(tz.local);
  final nextHour = now.add(Duration(hours: hourOffset));
  return tz.TZDateTime(
      tz.local, nextHour.year, nextHour.month, nextHour.day, nextHour.hour);
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => ExpenseTrackerApp(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegistrationScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => AuthWrapper(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => CategoriesScreen(),
      ),
      GoRoute(
        path: '/new_category',
        builder: (context, state) => NewCategoryScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => AccountScreen(),
        routes: [
          //transfer history
          GoRoute(
            path: 'transfer_history',
            builder: (context, state) => TransferHistoryScreen(),
          ),
          GoRoute(
            path: 'new_transfer',
            builder: (context, state) => CreateTransferScreen(),
          ),
          //new account
          GoRoute(
            path: 'new_account',
            builder: (context, state) => AddAccountScreen(),
          ),
          GoRoute(
            path: 'edit_account/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return AddAccountScreen(accountId: id);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Flutter Notion Budget Tracker",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            LoadingIndicator(),
          ],
        );
      },
    );
  }
}
