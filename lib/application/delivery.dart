import 'package:intl/intl.dart';

import '../domain/slot_model.dart';

class SlotProvider {
  String locationId;
  final List<SlotsModel> _deliverySlots = [];
  SlotProvider(
    this.locationId,
    this._deliveryCharges,
    this._deliverySlots,
    this.slotsDelivery,
    this.priceDelivery,
    this.delDelivery,
  );

  static const maximumAllowingBookingDays = 4;
  static const thresholdTimeBetweenOrders = 2;

  
  Map<String, List<SlotsModel>> slotsDelivery = {};
  Map<String, List<SlotsModel>> delDelivery = {};
  //parentId mapped with service Charge
  Map<String, Map<int, int>> priceDelivery = {};
  final Map<int, int> _deliveryCharges = {};
  Map<int, int> get deliveryCharges => {..._deliveryCharges};
  List<SlotsModel> get deliverySlots => [..._deliverySlots];
  int getDeliveryCharge1(num subTotal) {
    int total = subTotal;
    if (total < 149) {
      subTotal = 119;
    } else if (total > 149 && total < 299) {
      subTotal = 99;
    } else {
      subTotal = 79;
    }
    return subTotal;
  }

  int getDeliveryCharge(num subTotal, String parentId) {
    Map<int, int> price = priceDelivery[parentId];
    List<int> keyMap = [];
    keyMap = price.keys.toList();
    int total = subTotal;
    if (total < keyMap[1] - 1) {
      subTotal = price[0];
    } else if (total > keyMap[1] - 1 && total < keyMap[2] - 1) {
      subTotal = price[150];
    } else {
      subTotal = price[300];
    }
    return subTotal;
  }

  List<DateTime> getPickupDates(String parentId) {
    DateTime now = DateTime.now();
    //Check if any slot available for today
    DateTime startDate;
    //Check time available for today
    if (now.hour + thresholdTimeBetweenOrders < 24) {
      String minTime = DateFormat.Hm()
          .format(now.add(const Duration(hours: thresholdTimeBetweenOrders)));
      DateTime.now().day;
      //If slots available for day
      if (slotsDelivery[parentId]
          .any((slotItem) => slotItem.from.compareTo(minTime) >= 0)) {
        startDate = DateTime(now.year, now.month, now.day);
      } else {
        startDate = DateTime(now.year, now.month, now.day + 1);
      }
    }
    //Else Choose next day as start date
    else {
      startDate = DateTime(now.year, now.month, now.day + 1);
    }

    List<DateTime> response = [];
    for (int i = 0; i < maximumAllowingBookingDays; ++i) {
      response
          .add(DateTime(startDate.year, startDate.month, startDate.day + i));
    }
    return response;
  }

  List<SlotsModel> getPickupSlotsFor(DateTime selectedDate, String id) {
    final now = DateTime.now();
    //If selected date is today
    if (now.year == selectedDate.year &&
        now.month == selectedDate.month &&
        now.day == selectedDate.day) {
      DateTime now = DateTime.now();
      //Check if time available for today
      if (now.hour + thresholdTimeBetweenOrders < 24) {
        String minTime = DateFormat.Hm()
            .format(now.add(const Duration(hours: thresholdTimeBetweenOrders)));
        //Return left over slots for today
        return slotsDelivery[id]
            .where((item) => item.from.compareTo(minTime) >= 0)
            .toList();
        // return _deliverySlots
        //     .where((item) => item.from.compareTo(minTime) >= 0)
        //     .toList();
        //Return no slots for this date
      } else {
        return [];
      }
    }
    //Return all available slots cuz date is not today
    else {
      return slotsDelivery[id];
    }
  }

  List<DateTime> getDeliveryDatesFrom(
      DateTime pickupDate, int minutes, String parentId) {
    DateTime now = pickupDate.add(Duration(minutes: minutes));
    // log(now.toString());
    String minTime = DateFormat.Hm().format(now);
    DateTime startDate;
    //If any slots available in current the day
    if (delDelivery[parentId]
        .any((slotItem) => slotItem.from.compareTo(minTime) >= 0)) {
      startDate = DateTime(now.year, now.month, now.day);
      // log(startDate.toString());
    } else {
      startDate = DateTime(now.year, now.month, now.day + 1);
    }
    List<DateTime> response = [];
    response.add(startDate);
    for (int i = 1; i < maximumAllowingBookingDays; ++i) {
      response
          .add(DateTime(startDate.year, startDate.month, startDate.day + i));
    }
    return response;
  }

  List<SlotsModel> getDeliverySlotsFor(DateTime pickupDate,
      DateTime selectedDate, int minimumDeliveryTime, String id) {
    final now = pickupDate.add(Duration(minutes: minimumDeliveryTime));
    //If selected day in the closest day
    if (now.year == selectedDate.year &&
        now.month == selectedDate.month &&
        now.day == selectedDate.day) {
      String minTime = DateFormat.Hm().format(now);
      //Return available slot of that day
      return delDelivery[id]
          .where((item) => item.from.compareTo(minTime) >= 0)
          .toList();
      //if selected day has all slots available
    } else {
      return delDelivery[id];
    }
  }
}
