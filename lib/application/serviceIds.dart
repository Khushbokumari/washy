import 'package:flutter/material.dart';
import '../domain/order_item.dart';
import '../domain/slot_model.dart';

class ServiceIds with ChangeNotifier {
  List<String> serviceId = [];
  List<String> parentId = [];
  //map of (parentId and list<ServiceId>) present in the cart
  Map<String, List<String>> map = {};
  Map<String, Map<String, OrderTimeHandling>> mapOfParentIdsForSlots = {};
  int parentCount = 0;
  Map<String, SlotsModel> availableSlotsMap = {};
  Map<String, SlotsModel> availabledelSlotsMap = {};

  double walletMoney = 0;

  updateWalletMoney(double val) {
    walletMoney = val;
    notifyListeners();
  }

  updateMapOfParentIdsForSlots(
      String parentId, Map<String, OrderTimeHandling> mp) {
    mapOfParentIdsForSlots[parentId] = mp;
  }

  updateServiceIds(List<String> svcId) {
    serviceId = [];
    serviceId = svcId;
  }

  void updateselectedAvailable(String pId, SlotsModel selected) {
    availableSlotsMap[pId] = selected;
    notifyListeners();
  }

  void updatedeliveryAvailable(String pId, SlotsModel selected) {
    availabledelSlotsMap[pId] = selected;
    notifyListeners();
  }

  updateParentCount(int x) {
    parentCount = x;
  }

  updateParentIds(List<String> parId) {
    parentId = [];
    parentId = parId;
  }

  updateParentMap(Map<String, List<String>> mp) {
    map = mp;
  }

  resetMap() {
    mapOfParentIdsForSlots = {};
  }
}
