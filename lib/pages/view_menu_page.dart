import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/document_snapshot_id.dart';

class ViewMenu extends StatelessWidget {
  // ViewMenu({super.key, this.snapData});
  final String? snapData;

  late final CollectionReference _products;

  ViewMenu({super.key, this.snapData}) {
    _products = FirebaseFirestore.instance
        .collection('sellers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user-menu')
        .doc(snapData)
        .collection('sub-menu');
  }

  // final CollectionReference _products = FirebaseFirestore.instance
  //     .collection('sellers')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //     .collection('user-menu')
  //     .doc(context.watch<DocSnapShot>().docSnapshotId)
  //     .collection('sub-menu');

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sub Menu",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "add_sub_menu_page");
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "detail_menu_page");
                        },
                        child: Container(
                          height: height * 0.4,
                          width: width * 0.85,
                          color: Colors.grey[300],
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Image.network(
                                    documentSnapshot['menu-photo'],
                                    height: 200,
                                    width: 150,
                                    fit: BoxFit.cover),
                              ),
                              Text(
                                documentSnapshot['menu-title'],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(
            child:
                CircularProgressIndicator(color: Colors.greenAccent.shade200),
          );
        },
      ),
    );
  }
}
