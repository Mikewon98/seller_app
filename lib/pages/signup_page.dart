import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_app/global/global.dart';
import 'package:seller_app/widgets/custom_text_field.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:seller_app/widgets/loading_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  late final TextEditingController _address;

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  // Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  // String? _currentAddress;
  Position? _currentPosition;

  Future _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    placeMarks = await placemarkFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress =
        ' ${pMark.subThoroughfare},${pMark.thoroughfare},${pMark.locality},${pMark.administrativeArea}, ${pMark.country}';

    _address.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog(
            message: "Please select an image!",
          );
        },
      );
    } else {
      if (_password.text.isNotEmpty &&
          _confirmPassword.text.isNotEmpty &&
          _email.text.isNotEmpty &&
          _name.text.isNotEmpty &&
          _phone.text.isNotEmpty) {
        if (_password.text == _confirmPassword.text) {
          if (_password.text.length >= 6) {
            showDialog(
              context: context,
              builder: (context) {
                return const LoadingWidget(
                  message: "Registering",
                );
              },
            );

            String filename = DateTime.now().millisecondsSinceEpoch.toString();
            f_storage.Reference reference = f_storage.FirebaseStorage.instance
                .ref()
                .child("sellers")
                .child("profile-picture")
                .child(filename);
            f_storage.UploadTask uploadTask =
                reference.putFile(File(imageXFile!.path));
            f_storage.TaskSnapshot taskSnapShot = await uploadTask.whenComplete(
              () {},
            );

            await taskSnapShot.ref.getDownloadURL().then(
              (url) {
                sellerImageUrl = url;

                //save info to firestore

                authenticateSellerAndSignUp();
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return const ErrorDialog(
                  message:
                      "Password length must be greater than or equall to 6!",
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog(
                message: "Password doesn't match!",
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message:
                  "Please input the required infotmation for the Registration!",
            );
          },
        );
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    // try {
    //   await AuthService.firebase().createUser(
    //     email: email,
    //     password: password,
    //   );
    //   AuthService.firebase().sendEmailVerification();
    //   if (!mounted) return;
    //   Navigator.of(context).pushNamed("verify_email_page");
    // } on WeakPasswordAuthException {
    //   await showDialog(
    //       context: context,
    //       builder: (c) {
    //         return const ErrorDialog(message: "Password is weak!");
    //       });
    // } on InvalidEmailAuthException {
    //   await showDialog(
    //       context: context,
    //       builder: (c) {
    //         return const ErrorDialog(message: "Invalid Email");
    //       });
    // } on EmailAlreadyInUseException {
    //   await showDialog(
    //       context: context,
    //       builder: (c) {
    //         return const ErrorDialog(message: "Email has already registred");
    //       });
    // } on GenericAuthException {
    //   await showDialog(
    //       context: context,
    //       builder: (c) {
    //         return const ErrorDialog(message: "Failed to register");
    //       });
    // }

    User? currentUser;
    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then(
        (value) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "verify_email_page");
        },
      );
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    final docData = {
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": _name.text.trim(),
      "sellerPhone": _phone.text.trim(),
      "sellerAddress": completeAddress,
      "sellerAvatar": sellerImageUrl,
      "status": "approved",
      "earning": 0.0,
      "location":
          GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
    };

    FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .collection("user-info")
        .add(docData)
        .then((documentSnapshot) =>
            print("Added Data with ID: ${documentSnapshot.id}"));

    sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("name", _name.text.trim());
    await sharedPreferences!.setString("email;", currentUser.email.toString());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
    await sharedPreferences!.setString("phone", _phone.text.trim());
  }

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _address = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(204, 105, 216, 161),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 25),
                            child: Column(
                              children: [
                                const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 6, 156, 14),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Set up your profile",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Create an account to get the best delivery service!",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                InkWell(
                                  onTap: () {
                                    _getImage();
                                  },
                                  child: CircleAvatar(
                                    radius: MediaQuery.of(context).size.width *
                                        0.20,
                                    backgroundColor: Colors.white,
                                    backgroundImage: imageXFile == null
                                        ? null
                                        : FileImage(File(imageXFile!.path)),
                                    child: imageXFile == null
                                        ? Icon(
                                            Icons.add_photo_alternate,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.20,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Please input your image!",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        controller: _name,
                                        data: Icons.person,
                                        hintText: "Name",
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _email,
                                        data: Icons.email,
                                        hintText: "Email",
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _phone,
                                        data: Icons.phone,
                                        hintText: "Phone",
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _password,
                                        data: Icons.lock,
                                        hintText: "Password",
                                        isObscure: true,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _confirmPassword,
                                        data: Icons.lock,
                                        hintText: "Confirm Password",
                                        isObscure: true,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextField(
                                        controller: _address,
                                        data: Icons.my_location,
                                        hintText: "Address",
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 400,
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: ElevatedButton.icon(
                                          label: const Text(
                                            "Get my location",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          icon: const Icon(Icons.location_on,
                                              color: Colors.white),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            // get my location
                                            _getCurrentPosition();
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 25),
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 0, 199, 99),
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(150, 50),
                                          ),
                                          onPressed: () {
                                            formValidation();
                                          },
                                          child: const Text(
                                            "SignUp",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const TextBtnWidget(),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextBtnWidget extends StatelessWidget {
  const TextBtnWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {Navigator.pushNamed(context, "login_page")},
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "Already have an account? ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Color.fromARGB(255, 9, 161, 16),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
