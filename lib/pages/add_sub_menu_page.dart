import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_app/pages/view_menu_page.dart';
import 'package:seller_app/widgets/custom_text_field.dart';
import 'package:seller_app/widgets/error_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;

class AddSubMenuPage extends StatefulWidget {
  const AddSubMenuPage({super.key});

  @override
  State<AddSubMenuPage> createState() => _AddSubMenuPageState();
}

class _AddSubMenuPageState extends State<AddSubMenuPage> {
  late final TextEditingController _title;
  late final TextEditingController _info;

  String menuImageUrl = "";
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Future _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> menuValidation() async {
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
      if (_title.text.isNotEmpty && _info.text.isNotEmpty) {
        String filename = DateTime.now().millisecondsSinceEpoch.toString();

        f_storage.Reference reference = f_storage.FirebaseStorage.instance
            .ref()
            .child("sellers")
            .child("menu-picture")
            .child(filename);
        f_storage.UploadTask uploadTask =
            reference.putFile(File(imageXFile!.path));
        f_storage.TaskSnapshot taskSnapShot = await uploadTask.whenComplete(
          () {},
        );

        await taskSnapShot.ref.getDownloadURL().then(
          (url) {
            menuImageUrl = url;

            //save info to firestore

            sendMenuToFirestore();
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message:
                  "Please input the required infotmation for the Menu Registration!",
            );
          },
        );
      }
    }
  }

  String? docSnapShot;
  void sendMenuToFirestore() {
    final title = _title.text.trim();
    final info = _info.text.trim();

    final currentUser = FirebaseAuth.instance.currentUser!;

    // FirebaseFirestore.instance
    //     .collection("sellers")
    //     .doc(currentUser.uid)
    //     .collection("user-menu")
    //     .doc()
    //     .collection("sub-menu")
    // .add(docData)
    // .then((documentSnapshot) =>
    //     print("Added Data with ID: ${documentSnapshot.id}"));

    final docData = {
      'menu-info': info,
      'menu-title': title,
      'menu-photo': menuImageUrl,
    };

    FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .collection("user-menu")
        .doc()
        .collection("sub-menu")
        .add(docData)
        .then((documentSnapshot) => setState(() {
              print("Added Data with ID: ${documentSnapshot.id}");
              docSnapShot = documentSnapshot.id;
            }));

    // final CollectionReference _products = FirebaseFirestore.instance
    //     .collection('sellers')
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .collection('user-menu');

    // CollectionReference newCollection = _products.doc().collection('sub-menu');

    // DocumentReference docData = newCollection.doc();

    // docData.set({
    //   'menu-info': info,
    //   'menu-title': title,
    //   'menu-photo': menuImageUrl,
    //   // Add more fields as needed
    // });

    print("doc snapshot $docSnapShot");
  }

  @override
  void initState() {
    _title = TextEditingController();
    _info = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add new sub menu",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _getImage(),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.37,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageXFile == null
                      ? null
                      : FileImage(File(imageXFile!.path)),
                  child: imageXFile == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: MediaQuery.of(context).size.width * 0.20,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              // Icons.add_a_photo_outlined,
              CustomTextField(
                data: CupertinoIcons.textbox,
                controller: _title,
                hintText: "Title",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 340,
                child: TextField(
                  controller: _info,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "More info...",
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: InkWell(
                  onTap: () {
                    menuValidation();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewMenu(
                            snapData: docSnapShot,
                          ),
                        ),
                        (route) => false);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ViewMenu(
                    //       snapData: docSnapShot,
                    //     ),
                    //   ),
                    // );
                    // if (!mounted) return;
                    // Navigator.pop(context, docSnapShot);
                  },
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
