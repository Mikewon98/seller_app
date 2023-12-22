import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  signOutFn() {
    firebaseAuth.signOut();
    Navigator.pushReplacementNamed(context, "login_page");
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Michael Wondwossen"),
              accountEmail: const Text("Mikewon98@gmail.com"),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset("images/seller.png"),
                ),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(102, 16, 243, 129),
                    Color.fromARGB(153, 70, 189, 130),
                    Color.fromARGB(204, 65, 207, 136),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  runSpacing: 16,
                  children: [
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(CupertinoIcons.home),
                      ),
                      title: const Text("Home"),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "home_page");
                      },
                    ),
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(CupertinoIcons.money_dollar_circle),
                      ),
                      title: const Text("My earnings"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(CupertinoIcons.cart_badge_plus),
                      ),
                      title: const Text("New order"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(CupertinoIcons.list_dash),
                      ),
                      title: const Text("History"),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(Icons.logout),
                      ),
                      title: const Text("Logout"),
                      onTap: () {
                        signOutFn();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
