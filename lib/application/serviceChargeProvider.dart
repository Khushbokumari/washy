// ignore_for_file: file_names

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../domain/serviceprice.dart';

class ServiceChargeProvider with ChangeNotifier {
  static const String routeName = 'service-list-screen';
  List<ServicePrice> servicePriceList = [];
  List<String> parentId = [];

  Future<List<String>> getServiceCharge() async {
    final data = await FirebaseDatabase.instance
        .ref()
        .child("location")
        .child("PQbUolFy3Oglow9y4zTGtieHcp22")
        .child("services")
        .once();
    if (data.snapshot.value != null) {
      (data.snapshot.value as Map<String, dynamic>).forEach((key, value) {
        parentId.add(key);
      });
    }
    return parentId;
  }
}
