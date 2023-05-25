import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../domain/cart_model.dart';
import '../domain/order_item.dart';
import '../core/network/url.dart';

class CartProvider with ChangeNotifier {
  Map<String, Map<String, CartModel>> _items = {};
  Map<String, Map<String, CartModel>> get items => {..._items};

  Map<String, List<CartModel>> cartItemsWithParentId = {};
  Map<String, List<String>> parentServiceIdsMap = {};
  Map<String, num> parentSubtotalAmountMap = {};
  Map<String, String> parentIdNameMap = {};

  List<CartModel> get orderItems {
    List<CartModel> response = [];
    for (var item in _items.values) {
      for (var item in item.values) {
        response.add(item);
      }
    }
    return response;
  }

  Map<String, int> deliveryChargesMap = {};
  //Map<String, bool> checkMap = {};

  int getItemCountByCategoryAndService(String categoryName, String serviceID) {
    return _items[serviceID]?.values.toList().fold(0, (currPrev, currItem) {
          if (currItem.categoryName == categoryName) {
            return currPrev + currItem.quantity;
          } else {
            return currPrev;
          }
        }) ??
        0;
  }

  void updateParentServiceIdsMap(Map<String, List<String>> map) {
    parentServiceIdsMap = {};
    parentServiceIdsMap = map;
  }

  void expandItemsMap() {
    cartItemsWithParentId = {};
    parentServiceIdsMap.forEach((parentId, svcIds) {
      List<CartModel> list = [];
      for (var serviceId in svcIds) {
        _items[serviceId]?.values.toList().forEach((element) {
          list.add(element);
        });
      }
      cartItemsWithParentId[parentId] = list;
    });
    // notifyListeners();
  }

  Map<String, OrderAmount> getOrderAmountParentMap(num discount) {
    Map<String, OrderAmount> map = {};

    deliveryChargesMap.keys.toList().forEach((parentId) {
      map[parentId] = OrderAmount(
          subtotal: parentSubtotalAmountMap[parentId],
          delivery: deliveryChargesMap[parentId],
          discount: discount);
    });
    return map;
  }

  Map<String, num> getparentIdAmountMap() {
    parentSubtotalAmountMap = {};
    //mapping parent id's with their respective amount without service charge
    cartItemsWithParentId.keys.toList().forEach((parentId) {
      if (parentServiceIdsMap.containsKey(parentId)) {
        parentSubtotalAmountMap[parentId] = getAmountByParentId(parentId);
      }
    });
    return parentSubtotalAmountMap;
  }

  num getAmountByParentId(String parentId) {
    //getting the total amount of a given parent id
    num parentAmount = 0;
    for (var element in cartItemsWithParentId[parentId]!) {
      parentAmount += (element.price * element.quantity);
    }
    return (cartItemsWithParentId.containsKey(parentId)) ? parentAmount : 0;
  }

  updateDeliveryChargeMap(String parentId, int deliveryCharge) {
    deliveryChargesMap[parentId] = deliveryCharge;
  }

  num get totalAmount => _items.values.toList().fold(
        0,
        (prev, item) =>
            prev +
            item.values.toList().fold(
                0,
                (currPrev, currItem) =>
                    currPrev + currItem.price * currItem.quantity),
      );
  num get totalAmountservice => _items.values.toList().fold(
        0,
        (prev, item) =>
            prev +
            item.values.toList().fold(
                0,
                (currPrev, currItem) =>
                    currPrev + currItem.price * currItem.quantity),
      );

  int? totalAmountParent(List<String> listOfServiceIds) {
    int? total = 0;
    for (var element in listOfServiceIds) {
      _items[element]?.forEach((key, value) {
        total = (total! + value.price * value.quantity) as int?;
      });
    }
    return total;
  }

  Future<void> loadCart() async {
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cart')) {
      prefs.setString('cart', jsonEncode({}));
    } else {
      final data = jsonDecode(prefs.getString('cart')) as Map<String, dynamic>;
      data.forEach((serviceId, value) => _items.putIfAbsent(serviceId, () {
            final Map<String, CartModel> data = {};
            (value as Map<String, dynamic>).forEach((prodId, value) => data
                .putIfAbsent(prodId, () => CartModel.fromMappedObject(value)));
            return data;
          }));
    }
    notifyListeners();
  }

  Future<void> refreshSlotsDate() async {
    DateTime date = DateTime.now();
    const urll =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22.json";
    final response = await http.get(Uri.parse(urll));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData["refresh"] != date.day) {
      const urll =
          "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22.json";

      await http.patch(Uri.parse(urll),
          body: jsonEncode({"refresh": date.day}));
      responseData["services"].forEach((parId, value) {
        if (value["isOneTimeService"] == false) {
          value["delivery"]["del"].forEach((key, value) async {
            final urll =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parId/delivery/del/$key.json";
            await http.patch(Uri.parse(urll),
                body: jsonEncode({
                  "availableSlots": value["maxSlots"],
                }));
          });
          value["delivery"]["slots"].forEach((key, value) async {
            final urll =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parId/delivery/slots/$key.json";
            await http.patch(Uri.parse(urll),
                body: jsonEncode({"availableSlots": value["maxSlots"]}));
          });
        }
      });
    }
  }

  num? getAmount(String serviceId) {
    return _items.containsKey(serviceId)
        ? _items[serviceId]
            ?.values
            .toList()
            .fold(0, (prev, curr) => prev + curr.price * curr.quantity)
        : 0;
  }

  int? getProductAmount(String serviceId, String productId) {
    int? total = 0;
    if (_items.containsKey(serviceId)) {
      _items[serviceId]?.forEach((key, value) {
        if (key == productId) {
          total = (value.quantity * value.price) as int?;
        }
      });
    }
    return total;
  }

  Future<void> clearCart() async {
    _items = {};
    cartItemsWithParentId = {};
    parentServiceIdsMap = {};
    parentSubtotalAmountMap = {};
    parentIdNameMap = {};
    deliveryChargesMap = {};

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', jsonEncode(_items));
    notifyListeners();
  }

  Future<void> addItem({
    required String serviceId,
    required String productId,
    required CartModel item,
  }) async {
    //If service is already present
    if (_items.containsKey(serviceId)) {
      //If product is already present
      if (_items[serviceId]!.containsKey(productId)) {
        _items[serviceId]?.update(
          productId,
          (prev) => CartModel(
            categoryName: item.categoryName,
            title: prev.title,
            price: prev.price,
            quantity: prev.quantity + 1,
            id: prev.id,
            serviceName: prev.serviceName,
          ),
        );
        //Product not present
      } else {
        _items[serviceId].putIfAbsent(
          productId,
          () => CartModel(
            categoryName: item.categoryName,
            serviceName: item.serviceName,
            id: DateTime.now().toString(),
            quantity: 1,
            price: item.price,
            title: item.title,
          ),
        );
      }
      //service not present
    } else {
      _items.putIfAbsent(
        serviceId,
        () => {
          productId: CartModel(
            categoryName: item.categoryName,
            title: item.title,
            price: item.price,
            quantity: 1,
            id: DateTime.now().toString(),
            serviceName: item.serviceName,
          ),
        },
      );
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', jsonEncode(_items));
    notifyListeners();
  }

  int get totalQuantity => _items.values.toList().fold(
      0,
      (prev, curr) =>
          prev +
          curr.values
              .toList()
              .fold(0, (cPrev, cCurr) => cPrev + cCurr.quantity));

  int getQuantity(String productId) {
    return _items.values.toList().fold(0, (prev, curr) {
      if (curr.containsKey(productId)) {
        return prev + curr[productId].quantity;
      } else {
        return prev;
      }
    });
  }

  Future<void> updateCart(
      {@required String serviceId,
      @required String productId,
      @required CartModel cartItem}) async {
    //Perform update
    _items[serviceId].update(
      productId,
      (prev) => cartItem,
    );

    //ParentId of updated product
    String parentId;
    parentServiceIdsMap.forEach((key, value) {
      for (var element in value) {
        if (element == serviceId) parentId = key;
      }
    });

    //perform update in cartItemwithParentId
    for (var element in cartItemsWithParentId[parentId]) {
      if (element.id == cartItem.id) {
        element.quantity = cartItem.quantity;
      }
    }

    //Remove productId and category if any
    if (_items[serviceId][productId].quantity < 1) {
      var cartItem = _items[serviceId][productId];
      int index;
      _items[serviceId].remove(productId);

      for (int i = 0; i < cartItemsWithParentId[parentId].length; i++) {
        if (cartItemsWithParentId[parentId][i].id == cartItem.id) {
          index = i;
        }
      }
      cartItemsWithParentId[parentId].removeAt(index);
      if (_items[serviceId].values.toList().isEmpty) {
        _items.remove(serviceId);
        parentServiceIdsMap[parentId].remove(serviceId);

        if (parentServiceIdsMap[parentId].isEmpty) {
          parentServiceIdsMap.remove(parentId);
          parentSubtotalAmountMap.remove(parentId);
          deliveryChargesMap.remove(parentId);
          cartItemsWithParentId.remove(parentId);
          log('done');
        }
      }
    }
    //Save preferences
    final pref = await SharedPreferences.getInstance();
    pref.setString('cart', jsonEncode(_items));
    notifyListeners();
    return true;
  }

  Future<bool> removeItem({
    @required String serviceId,
    @required String productId,
  }) async {
    //If customized order
    if (_items.values
            .where((item) => item.containsKey(productId))
            .toList()
            .length >
        1) return false;
    //If current service item not present
    if (!items.containsKey(serviceId) ||
        !_items[serviceId].containsKey(productId)) {
      return true;
    }
    //If last item of product remove product
    if (_items[serviceId][productId].quantity < 2) {
      _items[serviceId].remove(productId);
      //If last product of service remove service
      if (_items[serviceId].values.toList().isEmpty) {
        _items.remove(serviceId);
      }
      //Reduce quantity by 1
    } else {
      _items[serviceId].update(
        productId,
        (prev) => CartModel(
          categoryName: prev.categoryName,
          serviceName: prev.serviceName,
          id: prev.id,
          quantity: prev.quantity - 1,
          price: prev.price,
          title: prev.title,
        ),
      );
    }
    final pref = await SharedPreferences.getInstance();
    pref.setString('cart', jsonEncode(_items));
    notifyListeners();
    return true;
  }
}
