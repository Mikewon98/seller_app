import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/services/auth/auth_service.dart';
import 'package:seller_app/widgets/custom_text_field.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:seller_app/widgets/forgot_btn_widget.dart';
import 'package:seller_app/widgets/loading_widget.dart';

import '../services/auth/auth_exceptions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  formValidation() async {
    if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog(
            message: "Please type your Email and Password!",
          );
        },
      );
    }
  }

  loginNow() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    showDialog(
      context: context,
      builder: (context) {
        return const LoadingWidget(
          message: "Cheaking Credentials",
        );
      },
    );

    // try {
    //   AuthService.firebase().logIn(
    //     email: email,
    //     password: password,
    //   );
    //   final currentUser = FirebaseAuth.instance.currentUser;
    //   if (currentUser != null) {
    //     readDataAndSetDataLocally(currentUser).then(
    //       (value) {
    //         Navigator.pop(context);
    //         Navigator.pushNamed(context, "profile_page");
    //       },
    //     );
    //   }
    // } on UserNotFoundAuthException {
    //   await showDialog(
    //       context: context,
    //       builder: (context) {
    //         return const ErrorDialog(
    //           message: "User not found",
    //         );
    //       });
    // } on WrongPasswordAuthException {
    //   await showDialog(
    //       context: context,
    //       builder: (context) {
    //         return const ErrorDialog(
    //           message: "Wrong password",
    //         );
    //       });
    // } on GenericAuthException {
    //   showDialog(
    //       context: context,
    //       builder: (context) {
    //         return const ErrorDialog(
    //           message: 'Authentication Error',
    //         );
    //       });
    // }

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            message: error.toString(),
          );
        },
      );
    });

    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, 'home_page');
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    try {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(currentUser.uid)
          .collection('user-info')
          .doc()
          .get()
          .then((snapshot) async {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!
            .setString("email", snapshot.data()!["sellerEmail"]);
        await sharedPreferences!
            .setString("name", snapshot.data()!["sellerName"]);
        await sharedPreferences!
            .setString("phone", snapshot.data()!["sellerPhone"]);
        await sharedPreferences!
            .setString("photoUrl", snapshot.data()!["sellerAvatar"]);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      // Handle the error or add more specific error handling logic here
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(102, 16, 243, 129),
                    Color.fromARGB(153, 70, 189, 130),
                    Color.fromARGB(204, 65, 207, 136),
                    Color.fromARGB(255, 18, 114, 82),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 120,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.card_giftcard_rounded,
                          color: Color.fromARGB(255, 2, 202, 45),
                        ),
                        Text(
                          'Zenon Food Delivery',
                          style: TextStyle(
                            color: Color.fromARGB(255, 18, 105, 0),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _email,
                      hintText: "Email",
                      data: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _password,
                      hintText: "Password",
                      isObscure: true,
                      data: Icons.lock,
                      autoCorrect: false,
                      enableSuggestion: false,
                    ),
                    const SizedBox(height: 20),
                    const ForgotBtnWidget(),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 0, 247, 124),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(150, 50),
                        ),
                        onPressed: () {
                          formValidation();
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const TextBtnWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class TextBtnWidget extends StatelessWidget {
  const TextBtnWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {Navigator.pushNamed(context, "signup_page")},
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "SignUp",
              style: TextStyle(
                color: Color.fromARGB(255, 6, 236, 17),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
