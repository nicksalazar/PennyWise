import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/l10n/l10n.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/providers/language_provider.dart';
import 'package:pennywise/providers/loading_provider.dart';
import 'package:pennywise/providers/transaction_provider.dart';
import 'package:pennywise/providers/transfer_provider.dart';
import 'package:pennywise/repositories/account_repository.dart';
import 'package:pennywise/repositories/transaction_repository.dart';
import 'package:pennywise/repositories/transfer_repository.dart';
import 'package:pennywise/screens/accounts/account_new_screen.dart';
import 'package:pennywise/screens/accounts/account_new_transfer_screen.dart';
import 'package:pennywise/screens/accounts/account_screen.dart';
import 'package:pennywise/screens/accounts/account_transfer_history_screen.dart';
import 'package:pennywise/screens/auth/auth_wrapper.dart';
import 'package:pennywise/screens/categories/categories_icons_catalog_screen.dart';
import 'package:pennywise/screens/categories/categories_screen.dart';
import 'package:pennywise/screens/home/home_screen.dart';
import 'package:pennywise/screens/auth/login_screen.dart';
import 'package:pennywise/screens/categories/categories_new_screen.dart';
import 'package:pennywise/screens/auth/register_screen.dart';
import 'package:pennywise/screens/settings/settings_screen.dart';
import 'package:pennywise/screens/splash_screen.dart';
import 'package:pennywise/screens/transactions/transaction_detail_screen.dart';
import 'package:pennywise/screens/transactions/transaction_screen.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:pennywise/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  //repositories
  AccountsRepository accountsRepository = AccountsRepository();
  TransferRepository transferRepository = TransferRepository();
  TransactionRepository transactionReporistory = TransactionRepository(
    firestore: FirebaseFirestore.instance,
  );

  //providers
  LoadingProvider loadingProvider = LoadingProvider();
  LanguageProvider languageProvider = LanguageProvider();
  TransferProvider transferProvider = TransferProvider(
    transferRepository,
    loadingProvider,
  );

  AccountProvider accountProvider = AccountProvider(
    accountsRepository,
    transferProvider,
    loadingProvider,
  );

  TransactionProvider transactionProvider = TransactionProvider(
    transactionReporistory,
    accountProvider,
    loadingProvider,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoadingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => languageProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => transactionProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => accountProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => transferProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(
            Provider.of<LoadingProvider>(context, listen: false),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/home', //transactions
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: 'new_transaction/:transactionType',
              builder: (context, state) {
                final transactionType = state.pathParameters['transactionType'];
                return TransactionScreen(
                  initialTransactionType: transactionType ?? 'expense',
                );
              },
            ),
            //transaction details
            GoRoute(
              path: 'transaction_detail/:id',
              builder: (context, state) => TransactionDetailScreen(
                transactionId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => CategoriesScreen(),
          routes: [
            GoRoute(
              path: 'new_category/:categoryType',
              builder: (context, state) => NewCategoryScreen(
                categoryType: state.pathParameters['categoryType']!,
              ),
            ),
            GoRoute(
              path: 'icon_catalog',
              builder: (context, state) => IconsCatalogScreen(),
            )
          ],
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
        GoRoute(
          path: '/auth',
          builder: (context, state) => AuthWrapper(),
          routes: [
            GoRoute(
              path: 'register',
              builder: (context, state) => RegistrationScreen(),
            ),
            GoRoute(
              path: 'login',
              builder: (context, state) => LoginScreen(),
            ),
            GoRoute(
              path: 'logout',
              builder: (context, state) {
                Provider.of<AuthProvider>(context, listen: false)
                    .signOut()
                    .then(
                  (value) {
                    GoRouter.of(context).go('/auth/login');
                  },
                );
                return Container();
              },
            ),
          ],
        ),
        //Logout
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
      return MaterialApp.router(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('es', ''),
          Locale('pt', ''),
        ],
        locale: languageProvider.currentLocale,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
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
    });
  }
}
