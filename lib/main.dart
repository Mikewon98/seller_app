import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:seller_app/pages/add_menu_page.dart';
import 'package:seller_app/pages/add_sub_menu_page.dart';
import 'package:seller_app/pages/cart_page.dart';
import 'package:seller_app/pages/detail_menu_page.dart';
import 'package:seller_app/pages/history_page.dart';
import 'package:seller_app/pages/home_page.dart';
import 'package:seller_app/pages/login_page.dart';
import 'package:seller_app/pages/my_earning_page.dart';
import 'package:seller_app/pages/new_order_page.dart';
import 'package:seller_app/pages/profile_page.dart';
import 'package:seller_app/pages/search_page.dart';
import 'package:seller_app/pages/signup_page.dart';
import 'package:seller_app/pages/verify_email_page.dart';
import 'package:seller_app/pages/view_menu_page.dart';
import 'package:seller_app/provider/document_snapshot_id.dart';
import 'package:seller_app/screens/main_screen.dart';
import 'package:seller_app/splash_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'global/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => DocSnapShot())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(213, 105, 216, 160),
        ),
      ),
      initialRoute: "login_page",
      routes: {
        "/": (context) => const SplashScreen(),
        "home_page": (context) => const HomePage(),
        "cart_page": (context) => const CartPage(),
        "login_page": (context) => const LoginPage(),
        "signup_page": (context) => const SignupPage(),
        "search_page": (context) => const SearchPage(),
        "profile_page": (context) => const ProfilePage(),
        "main_screen": (context) => const MainScreen(),
        "view_menu": (context) => ViewMenu(),
        "add_menu_page": (context) => const AddMenuPage(),
        "add_sub_menu_page": (context) => const AddSubMenuPage(),
        "detail_menu_page": (context) => const DetailMenuPage(),
        "history_page": (context) => const HistoryPage(),
        "my_earning_page": (context) => const MyEarningPage(),
        "new_order_page": (context) => const NewOrderPage(),
        "verify_email_page": (context) => const VerifyEmailPage(),
      },
    );
  }
}
