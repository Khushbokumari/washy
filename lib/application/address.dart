import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/address_model.dart';
import '../core/network/url.dart';
import '../core/utils/exceptions.dart';

class AddressProvider with ChangeNotifier {
  List<AddressModel> _address = [];

  List<AddressModel> get addresses => [..._address];

  String userId;
  String auth;
  bool init = true;

  AddressProvider(this.userId, this.auth);

  Future<void> fetchAndSetAddress([bool refresh = false]) async {
    if (!init && !refresh) return;
    _address = [];
    final url = "${URL.ADDRESSES_DATABASE_URL}/$userId.json?auth=$auth";
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      responseData.forEach((addressId, item) =>
          _address.add(AddressModel.fromMappedObject(addressId, item)));
      notifyListeners();
      init = false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeAddress(String id) async {
    final url = "${URL.ADDRESSES_DATABASE_URL}/$userId/$id.json?auth=$auth";
    int index = _address.indexWhere((item) => item.id == id);
    AddressModel? element = _address[index];
    //Optimistic Delete
    _address.removeAt(index);
    notifyListeners();
    try {
      final response = await http.delete(Uri.parse(url));
      //if failed
      if (response.statusCode >= 400) {
        _address.insert(index, element);
        notifyListeners();
        throw HttpException("Could not delete address.");
      }
      element = null;
    } catch (e) {
      _address.insert(index, element!);
      notifyListeners();
      throw HttpException("Could not delete address.");
    }
  }

  Future<void> updateAddress(AddressModel address, String id) async {
    var url = "${URL.ADDRESSES_DATABASE_URL}/$userId/$id.json?auth=$auth";
    try {
      await http.patch(Uri.parse(url), body: jsonEncode(address));
      int index = _address.indexWhere((item) => item.id == id);
      _address.removeAt(index);
      _address.insert(
        0,
        AddressModel(
            id: id,
            lng: address.lng,
            lat: address.lat,
            landmark: address.landmark,
            contactNumber: address.contactNumber,
            contactName: address.contactName,
            addressText: address.addressText,
            title: address.title),
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAddress(AddressModel item) async {
    var url = "${URL.ADDRESSES_DATABASE_URL}/$userId.json?auth=$auth";
    try {
      final response = await http.post(Uri.parse(url), body: jsonEncode(item));
      if (response.statusCode >= 400) {
        throw HttpException("Network Error");
      } else {
        _address.insert(
          0,
          AddressModel(
              id: jsonDecode(response.body)['name'],
              lng: item.lng,
              lat: item.lat,
              landmark: item.landmark,
              contactNumber: item.contactNumber,
              contactName: item.contactName,
              addressText: item.addressText,
              title: item.title),
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
