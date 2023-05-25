import 'package:washry/domain/address_model.dart';
import 'package:washry/domain/cart_model.dart';
import 'package:washry/domain/slot_model.dart';

class OrderAmount {
  num subtotal;
  num delivery;
  num discount;
  num tip;

  OrderAmount({
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.tip,
  });

  OrderAmount.fromMappedObject(Map<String, dynamic> item) {
    subtotal = item['subtotal'];
    delivery = item['serviceCharge'];
    discount = item['discount'];
    tip = item['tip'];
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'serviceCharge': delivery,
      'discount': discount,
      'tip': tip,
    };
  }
}

class OrderTimeHandling {
  SlotsModel timeSlot;
  DateTime expected;
  DateTime actual;

  OrderTimeHandling(this.expected, this.timeSlot);

  OrderTimeHandling.fromMappedObject(Map<String, dynamic> item) {
    timeSlot = SlotsModel(
        slotId: null,
        from: item['timeSlot']['from'],
        to: item['timeSlot']['to']);
    expected = DateTime.parse(item['expectedDate']);
    actual =
        (item['actualDate'] == null ? null : DateTime.parse(item['actualDate']))!;
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot,
      'expectedDate': expected.toIso8601String(),
      'actualDate': actual.toIso8601String(),
    };
  }
}

enum ServiceStatus { Pending, Accepted, In_Process, Completed, Cancelled }

class CategoryItems {
  //items filtered on the basis of parent id
  List<CartModel> items = [];
  ServiceStatus serviceStatus;
  OrderTimeHandling pickup;
  OrderTimeHandling delivery;
  OrderAmount categoryAmount;
  String parentName;

  CategoryItems({
    // this.parentId,
    required this.items,
    required this.categoryAmount,
    required this.delivery,
    required this.pickup,
    this.serviceStatus = ServiceStatus.Pending,
    required this.parentName,
  });
  CategoryItems.fromMappedObject(Map<String, dynamic> categoryItem) {
    //To do
    final amount = categoryItem['subOrderAmount'] as Map<String, dynamic>;
    categoryAmount = OrderAmount.fromMappedObject(amount);
    final pickupTime = categoryItem['pickup'] as Map<String, dynamic>;
    pickup = OrderTimeHandling.fromMappedObject(pickupTime);
    if (categoryItem.containsKey('delivery')) {
      final deliveryTime = categoryItem['delivery'] as Map<String, dynamic>;
      delivery = OrderTimeHandling.fromMappedObject(deliveryTime);
    } else {
      delivery = null;
    }
    serviceStatus = ServiceStatus.values[categoryItem['serviceStatus']];

    for (Map<String, dynamic> item in categoryItem['items']) {
      items.add(CartModel.fromMappedObject(item));
    }
    parentName = categoryItem['parentName'];
  }
  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup,
      'delivery': delivery,
      'subOrderAmount': categoryAmount,
      'serviceStatus': serviceStatus.index,
      'items': items,
      'parentName': parentName,
    };
  }
}

enum OrderStatus {
  Pending,
  Partial_Accepted,
  Accepted,
  Partial_InProcess,
  In_Process,
  Partial_Completed,
  Completed,
  Partial_Cancelled,
  Cancelled,
}

class OrderItem {
  String id;
  DateTime orderTime;
  String promoCodeId;
  bool hasPaid;
  Map<String, String> payment = {};
  String instructions;
  String userId;
  String locationId;
  AddressModel address;
  OrderAmount totalAmount;
  // OrderAmount amount;
  OrderStatus orderStatus;
  // OrderTimeHandling pickup;
  // OrderTimeHandling delivery;
  //List<CartModel> items = [];
  Map<String, CategoryItems> categoryItems = {};
  OrderItem({
    required this.id,
    required this.orderTime,
    required this.userId,
    required this.payment,
    required this.instructions,
    required this.locationId,
    required this.address,
    this.hasPaid = false,
    required this.promoCodeId,
    required this.categoryItems,
    required this.totalAmount,
    this.orderStatus = OrderStatus.Pending,
  });

  OrderItem.fromMappedObject(this.id, Map<String, dynamic> item) {
    orderTime = DateTime.parse(item['orderTime']);
    promoCodeId = item['promoCodeId'];
    hasPaid = item['hasPaid'];
    userId = item['userId'];
    locationId = item['locationId'];
    final paymentMap = item['payment'] as Map<String, dynamic>;
    paymentMap.forEach((key, value) {
      payment[key] = value;
    });
    instructions = item['instructions'] ?? 'No Instructions';
    final addressItem = item['address'] as Map<String, dynamic>;
    address = AddressModel.fromMappedObjectWithoutId(addressItem);
    final catergoryItem = item['subOrders'] as Map<String, dynamic>;
    totalAmount = OrderAmount.fromMappedObject(item['totalAmount']);
    catergoryItem.forEach((key, value) {
      categoryItems[key] = CategoryItems.fromMappedObject(value);
    });

    orderStatus = OrderStatus.values[item['orderStatus']];
  }

  get dateTime => null;

  Map<String, dynamic> toJson() {
    return {
      'orderTime': orderTime.toIso8601String(),
      'promoCodeId': promoCodeId,
      'hasPaid': hasPaid,
      'userId': userId,
      'locationId': locationId,
      'payment': payment,
      'instructions': instructions,
      'address': address,
      'subOrders': categoryItems,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus.index,
    };
  }
}
