import 'package:flutter/material.dart';
import 'package:seller_app/pages/cart_page.dart';
// import 'package:seller_app/pages/home_page.dart';
import 'package:seller_app/pages/profile_page.dart';
import 'package:seller_app/pages/search_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      // const HomePage(),
      const SearchPage(),
      const CartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        selectedItemColor: Colors.green,
        unselectedItemColor: const Color.fromARGB(204, 105, 216, 161),
        elevation: 0,
        selectedFontSize: 16,
        onTap: onTap,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
