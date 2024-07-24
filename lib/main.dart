import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_harmony/providers/Income_provider.dart';
import 'package:habit_harmony/providers/expense_provider.dart';
import 'package:habit_harmony/providers/hydration_provider.dart';
import 'package:habit_harmony/providers/transaction_provider.dart';
import 'package:habit_harmony/repositories/hydration_repository.dart';
import 'package:habit_harmony/screens/auth_wrapper.dart';
import 'package:habit_harmony/screens/home_screen.dart';
import 'package:habit_harmony/screens/login_screen.dart';
import 'package:habit_harmony/screens/splash_screen.dart';
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

  runApp(
    MultiProvider(
      providers: [
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
            ..fetchPaymentMethods(),
        ),
        ChangeNotifierProvider(
          create: (_) => IncomeProvider()
            ..fetchCategories()
            ..fetchIncomes()
            ..fetchReceptionMethods(),
        )
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
      _nextInstanceOfTenMinutes(i * 10),
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

tz.TZDateTime _nextInstanceOfTenMinutes(int minutesFromNow) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    now.hour,
    (now.minute ~/ 10) * 10,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(minutes: 10));
  }
  return scheduledDate.add(Duration(minutes: minutesFromNow));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Notion Budget Tracker",
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/auth': (context) => AuthWrapper(),
      },
    );
  }
}
