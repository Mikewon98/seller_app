import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:seller_app/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudMenu {
  final String sellerUid;
  final String sellerEmail;
  final String sellerName;
  final String sellerAddress;
  final String sellerAvatar;
  final int sellerPhone;
  final GeoPoint location;
  final double earnings;
  final String status;

  const CloudMenu(
    this.sellerName,
    this.sellerUid,
    this.sellerAddress,
    this.sellerAvatar,
    this.sellerEmail,
    this.sellerPhone,
    this.location,
    this.earnings,
    this.status,
  );

  CloudMenu.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : sellerUid = snapshot.data()[ownerUserId],
        sellerName = snapshot.data()[userName] as String,
        sellerAddress = snapshot.data()[userAddress] as String,
        sellerAvatar = snapshot.data()[userAvatar],
        sellerPhone = snapshot.data()[userPhone],
        sellerEmail = snapshot.data()[userEmail] as String,
        earnings = snapshot.data()[userEarning],
        location = snapshot.data()[userLocation],
        status = snapshot.data()[userStatus] as String;
}
