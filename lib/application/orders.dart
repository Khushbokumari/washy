import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/address_model.dart';
import '../domain/cart_model.dart';
import '../domain/order_item.dart';
import '../core/network/url.dart';
import '../core/utils/exceptions.dart';

class Orders with ChangeNotifier {
  String userId;
  String auth;

  Orders(this.userId, this.auth);

  bool init = true;
  OrderTimeHandling delivery;
  OrderTimeHandling pickup;
  OrderAmount totalAmount =
      OrderAmount(subtotal: 0, delivery: 0, discount: 0, tip: 0);

  Map<String, String> parentIdNameMap = {};
  List<OrderItem> _orders = [];
  final OrderItem _currentOrder = OrderItem();
  List<String> parentIds = [];
  Map<String, List<CartModel>> itemsWithParentId = {};
  Map<String, OrderAmount> parentOrderAmount = {};
  List<OrderItem> get orders => [..._orders];

  void addInstructionToCurrentOrder(String instructions) {
    _currentOrder.instructions = instructions;
  }

  void setOrders(List<OrderItem> order) {
    _orders = [];
    for (var element in order) {
      if (!_orders.contains(element)) _orders.add(element);
    }
  }

  void addPaymentModeToCurrentOrder(String paymentMode) {
    _currentOrder.payment = {};
    _currentOrder.payment['paymentMode'] = paymentMode;
    if (paymentMode == 'Washry Wallet' || paymentMode == 'UPI Payment') {
      _currentOrder.hasPaid = true;
    } else {
      _currentOrder.hasPaid = false;
    }
  }

  void addProductsToCurrentOrder(Map<String, List<CartModel>> itemMap) {
    parentIds = itemMap.keys.toList();
    itemsWithParentId = itemMap;
  }

  void getParentIdNameMap(Map<String, String> map) {
    parentIdNameMap = map;
  }

  void addAddressToCurrentOrder(AddressModel address) {
    _currentOrder.address = address;
  }

  void addDiscountAndTipToCurrentOrder(num discount, num tip) {
    totalAmount.discount = discount;
    totalAmount.tip = tip;
  }

  void addAmountToCurrentOrder(Map<String, OrderAmount> amountMap) {
    parentOrderAmount = amountMap;
    var totalSubtotal = 0;
    var totaldeliveryCharge = 0;
    amountMap.forEach((key, value) {
      totalSubtotal += value.subtotal;
      totaldeliveryCharge += value.delivery;
    });
    totalAmount.subtotal = totalSubtotal;
    totalAmount.delivery = totaldeliveryCharge;
  }

  OrderTimeHandling getCurrentOrderPickup() {
    return pickup;
  }

  OrderTimeHandling getCurrentOrderDelivery() {
    return delivery;
  }

  void addDeliveryToCurrentOrder(OrderTimeHandling delivery1) {
    delivery = delivery;
  }

  void addPickupToCurrentOrder(OrderTimeHandling pickup1) {
    pickup = pickup1;
  }

  String getCurrentOrderPromoCode() {
    return _currentOrder.promoCodeId;
  }

  void addPromoCodeToCurrentOrder(String promoCodeId) {
    _currentOrder.promoCodeId = promoCodeId;
  }

  Future<String> addOrder(
      String locationId,
      Map<String, Map<String, OrderTimeHandling>> mapp,
      Map<String, bool> servicesNature) async {
    _currentOrder.userId = userId;
    _currentOrder.locationId = locationId;
    _currentOrder.orderTime = DateTime.now();
    _currentOrder.totalAmount = totalAmount;

    _currentOrder.categoryItems = {};

    for (var parentId in parentIds) {
      CategoryItems categoryItem = CategoryItems();
      categoryItem.items = itemsWithParentId[parentId];
      categoryItem.categoryAmount = parentOrderAmount[parentId];
      categoryItem.parentName = parentIdNameMap[parentId];
      if (!servicesNature[parentId]) {
        categoryItem.delivery = mapp[parentId]['delivery'];
      }
      categoryItem.pickup = mapp[parentId]['pickup'];
      _currentOrder.categoryItems[parentId] = categoryItem;
    }
    var url = "${URL.ORDERS_DATABASE_URL}.json?auth=$auth";
    try {
      final response =
          await http.post(Uri.parse(url), body: jsonEncode(_currentOrder));
      if (response.statusCode >= 400) {
        throw HttpException("Network Error");
      } else {
        String id = jsonDecode(response.body)['name'];
        _orders.insert(
          0,
          OrderItem(
            id: jsonDecode(response.body)['name'],
            address: _currentOrder.address,
            userId: _currentOrder.userId,
            locationId: _currentOrder.locationId,
            hasPaid: _currentOrder.hasPaid,
            instructions: _currentOrder.instructions,
            orderTime: _currentOrder.orderTime,
            payment: _currentOrder.payment,
            promoCodeId: _currentOrder.promoCodeId,
            categoryItems: _currentOrder.categoryItems,
            totalAmount: _currentOrder.totalAmount,
          ),
        );
        notifyListeners();
        return id;
      }
    } catch (e) {
      rethrow;
    }
  }

  int getTimesApplied(String promoId) {
    return _orders.fold(
        0, (prev, curr) => curr.promoCodeId == promoId ? ++prev : prev);
  }

  Future<DateTime> getLastApplied(String promoId) async {
    await fetchAndSetOrders(true);
    if (_orders.isEmpty) return null;
    return (_orders.firstWhere((item) => item.promoCodeId == promoId,
        orElse: () => null)).orderTime;
  }

  Future<void> fetchAndSetOrders([bool refresh = true]) async {
    if (!init && !refresh) return;
    _orders = [];

    var filterString = 'orderBy="userId"&equalTo="$userId"';
    var url = '${URL.ORDERS_DATABASE_URL}.json?auth=$auth&$filterString';
    try {
      var response = await http.get(Uri.parse(url));

      var responseData = jsonDecode(response.body) as Map<String, dynamic>;
      // log(responseData.toString());
      responseData.forEach(
          (id, item) => _orders.add(OrderItem.fromMappedObject(id, item)));
      _orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));
      notifyListeners();
      init = false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelOrder(OrderItem item) async {
    int index = _orders.indexWhere((currItem) => currItem.id == item.id);
    String id = item.id;
    OrderItem item2 = item;
    //OrderStatus orderStatus = item.orderStatus;
    //item.orderStatus = OrderStatus.Cancelled;
    item.categoryItems.forEach((parentId, categoryItems) {
      categoryItems.serviceStatus = ServiceStatus.Cancelled;
    });

    item.id = null;
    final url = '${URL.ORDERS_DATABASE_URL}/$id.json?auth=$auth';
    try {
      final response =
          await http.patch(Uri.parse(url), body: jsonEncode(item.toJson()));
      if (response.statusCode >= 400) throw HttpException("Network Error");
      item.id = id;
      _orders.removeAt(index);
      _orders.insert(index, item);
      notifyListeners();
    } catch (e) {
      item = item2;
      rethrow;
    }
  }
}
