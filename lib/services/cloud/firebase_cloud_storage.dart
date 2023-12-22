import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seller_app/services/cloud/cloud_menu.dart';
import 'package:seller_app/services/cloud/cloud_storage_constants.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  User? currentUser;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  final sellers = FirebaseFirestore.instance.collection('sellers');

  Future<CloudMenu> createNewMenu({required String sellerUid}) async {
    await sellers.doc(currentUser!.uid).collection(userInfo).add({
      ownerUserId: sellerUid,
      userName: '',
      userAddress: '',
      userAvatar: '',
      userEarning: 0,
      userLocation: const GeoPoint(0, 0),
      userEmail: '',
      userPhone: 0,
      userStatus: 'approved',
    });
    return CloudMenu(
      '',
      sellerUid,
      '',
      '',
      '',
      0,
      const GeoPoint(0, 0),
      0,
      'approved',
    );
  }
}
