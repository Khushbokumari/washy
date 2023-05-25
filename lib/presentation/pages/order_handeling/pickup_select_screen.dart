import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:washry/domain/order_item.dart';
import 'package:washry/domain/service_model.dart';
import 'package:washry/domain/slot_model.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/delivery.dart';
import 'package:washry/application/orders.dart';
import 'package:washry/application/serviceIds.dart';
import 'package:washry/application/services.dart';
import '../../../presentation/pages/payment/payment_screen.dart';
import '../../../presentation/components/bottom_fixed_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PickupSelectScreen extends StatefulWidget {
  static const routeName = "Pickup-Select-Screen";

  PickupSelectScreen({Key ?key});

  @override
  _PickupSelectScreenState createState() => _PickupSelectScreenState();
}

class _PickupSelectScreenState extends State<PickupSelectScreen> {
  late String parentId;
  late ServiceModel tempNode;
  late List<DateTime> _pickUpDates;
  late List<DateTime> _deliveryDates;
  late DateTime _selectedDate;
  late DateTime _selectedDateForDelivery;
  late DateTime _startDate;
  late int _minutesFromPickupSlot;
  late SlotsModel _selectedSlot;
  late SlotsModel _selectedDeliverySlot;

  Widget get _appBar => AppBar(
        title: const Text('Choose Date & Time'),
      );

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _setInitialSelection();
    _setInitialSelectionForDelivery();
  }

  void _setInitialSelection() {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];
    final deliveryData = Provider.of<SlotProvider>(context, listen: false);
    _pickUpDates = deliveryData.getPickupDates(parId);
    _selectedDate = _pickUpDates[0];
    _selectedSlot = deliveryData.getPickupSlotsFor(_selectedDate, parId)[0];
    Provider.of<Orders>(context, listen: false).addPickupToCurrentOrder(
        OrderTimeHandling(_selectedDate, _selectedSlot));
  }

  void _setInitialSelectionForDelivery() async {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];
    final deliveryData = Provider.of<SlotProvider>(context, listen: false);
    final orderData = Provider.of<Orders>(context, listen: false);
    var servicesProvier = Provider.of<ServiceProvider>(context, listen: false);
    ServiceModel temp = servicesProvier.getParentInfo(svcIds.map[parId][0]);
    tempNode = temp;
    bool isOneTime;

    if (temp is MultiServiceModel) {
      isOneTime = temp.isOneTimeService;
    } else if (temp is SingleServiceModel) {
      isOneTime = temp.isOneTimeService;
    }
    if (!isOneTime) {
      _startDate = orderData.getCurrentOrderPickup().expected;
      _minutesFromPickupSlot = _getMinimumDeliveryTimeFrom(
          orderData.getCurrentOrderPickup().timeSlot.from);
      _deliveryDates = deliveryData.getDeliveryDatesFrom(
          _startDate, _minutesFromPickupSlot, parId);

      _selectedDateForDelivery = _deliveryDates[0];

      _selectedDeliverySlot = deliveryData.getDeliverySlotsFor(_startDate,
          _selectedDateForDelivery, _minutesFromPickupSlot, parId)[0];

      Provider.of<Orders>(context, listen: false).addDeliveryToCurrentOrder(
          OrderTimeHandling(_selectedDateForDelivery, _selectedDeliverySlot));
    }
  }

  int _getMinimumDeliveryTimeFrom(String pickupTime) {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];
    final serviceData = Provider.of<ServiceProvider>(context, listen: false);
    int maxDeliveryTime = 0;
    try {
      Provider.of<CartProvider>(context, listen: false)
          .parentServiceIdsMap[parId]
          ?.forEach((item) {
        int time = serviceData.getMinServiceTime(item);
        if (time > maxDeliveryTime) maxDeliveryTime = time;
      });
    } catch (e) {
      log(e.toString());
    }

    maxDeliveryTime *= 60;
    maxDeliveryTime += int.parse(pickupTime.substring(0, 2)) * 60;
    maxDeliveryTime += int.parse(pickupTime.substring(3, 5));
    return maxDeliveryTime;
  }

  String _getFormattedDate(DateTime orderTime) {
    var today = DateTime.now();
    if (orderTime.day == today.day &&
        orderTime.month == today.month &&
        orderTime.year == today.year) {
      return 'Today, ${DateFormat.MMMd().format(orderTime)}';
    } else if (orderTime.day == today.day + 1 &&
        orderTime.month == today.month &&
        orderTime.year == today.year) {
      return 'Tomorrow, ${DateFormat.MMMd().format(orderTime)}';
    } else {
      return DateFormat("EEEE, MMM d").format(orderTime).toString();
    }
  }

  String _getFormattedDateForDelivery(DateTime orderTime) {
    var today = DateTime.now();
    if (orderTime.day == today.day &&
        orderTime.month == today.month &&
        orderTime.year == today.year) {
      return 'Today, ${DateFormat.MMMd().format(orderTime)}';
    } else if (orderTime.day == today.day + 1 &&
        orderTime.month == today.month &&
        orderTime.year == today.year) {
      return 'Tomorrow, ${DateFormat.MMMd().format(orderTime)}';
    } else {
      return DateFormat("EEEE, MMM d").format(orderTime).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var svcIds = Provider.of<ServiceIds>(context, listen: false);
    var servicesProvier = Provider.of<ServiceProvider>(context, listen: false);
    int x = svcIds.parentCount; //index variable for list of parent id's
    String parId = svcIds.parentId[x];
    ServiceModel temp = servicesProvier.getParentInfo(svcIds.map[parId][0]);
    tempNode = temp;
    String parName = "";
    bool isOneTime;

    if (temp is MultiServiceModel) {
      isOneTime = temp.isOneTimeService;
      parName = temp.parentName;
    } else if (temp is SingleServiceModel) {
      isOneTime = temp.isOneTimeService;
      parName = temp.serviceName;
    }
    final deliveryData = Provider.of<SlotProvider>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: _appBar,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: !isOneTime
                        ? Text(
                            'Choose Pickup Date for $parName',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          )
                        : Text(
                            'Choose Date for $parName',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                  SizedBox(height: 50, child: _getDateList(deliveryData)),
                  const Divider(),
                  ListTile(
                    title: !isOneTime
                        ? Text(
                            'Choose Pickup Time for $parName',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          )
                        : Text(
                            'Choose Time for $parName',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Wrap(children: _getSlotsList(deliveryData)),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
              ),
              !isOneTime
                  ? const Divider(
                      color: Colors.blue,
                      thickness: 1,
                    )
                  : Container(),
              SizedBox(
                height: height * .01,
              ),
              !isOneTime
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            'Choose Delivery Date for $parName',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                            height: 50,
                            child: _getDateListForDelivery(deliveryData)),
                        const Divider(),
                        ListTile(
                            title: Text(
                          ' Choose Delivery Time for $parName',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        )),
                        Align(
                          alignment: Alignment.center,
                          child: Wrap(
                              direction: Axis.horizontal,
                              children: _getSlotsListForDelivery(deliveryData)),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
        bottomNavigationBar:
            BottomFixedButton(text: 'Next', onPressed: () => _saveCallback()),
      ),
    );
  }

  Widget _getDateList(SlotProvider deliveryData) {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x]; //current parent id

    return ListView(
      scrollDirection: Axis.horizontal,
      children: _pickUpDates
          .map((item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  label: Text(
                    _getFormattedDate(item),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _selectedDate == item,
                  onSelected: (_) {
                    setState(() {
                      _selectedDate = item;
                      _selectedSlot = deliveryData.getPickupSlotsFor(
                          _selectedDate, parId)[0];
                      Provider.of<Orders>(context, listen: false)
                          .addPickupToCurrentOrder(OrderTimeHandling(
                        _selectedDate,
                        _selectedSlot,
                      ));
                      _setInitialSelectionForDelivery();
                    });
                  },
                ),
              ))
          .toList(),
    );
  }

  List<Widget> _getSlotsList(SlotProvider deliveryData) {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];

    return deliveryData.getPickupSlotsFor(_selectedDate, parId).map((item) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          selected: _selectedSlot == item,
          label: Column(
            children: [
              Text(
                item.formattedTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Available Slots ${item.availableSlots}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onSelected: (_) {
            setState(() {
              _selectedSlot = item;
              Provider.of<Orders>(context, listen: false)
                  .addPickupToCurrentOrder(OrderTimeHandling(
                _selectedDate,
                _selectedSlot,
              ));
              _setInitialSelectionForDelivery();
            });
          },
        ),
      );
    }).toList();
  }

  Widget _getDateListForDelivery(SlotProvider deliveryData) {
    final orderData = Provider.of<Orders>(context, listen: false);
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];

    return ListView(
      scrollDirection: Axis.horizontal,
      children: _deliveryDates
          .map((item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  label: Text(
                    _getFormattedDateForDelivery(item),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _selectedDateForDelivery == item,
                  onSelected: (_) {
                    setState(() {
                      _startDate = orderData.getCurrentOrderPickup().expected;
                      _minutesFromPickupSlot = _getMinimumDeliveryTimeFrom(
                          orderData.getCurrentOrderPickup().timeSlot.from);
                      _deliveryDates = deliveryData.getDeliveryDatesFrom(
                          _startDate, _minutesFromPickupSlot, parId);

                      _selectedDateForDelivery = _deliveryDates[0];

                      _selectedDateForDelivery = item;
                      _selectedDeliverySlot = deliveryData.getDeliverySlotsFor(
                          _startDate,
                          _selectedDateForDelivery,
                          _minutesFromPickupSlot,
                          parId)[0];
                    });
                  },
                ),
              ))
          .toList(),
    );
  }

  List<Widget> _getSlotsListForDelivery(SlotProvider deliveryData) {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    String parId = svcIds.parentId[x];

    return deliveryData
        .getDeliverySlotsFor(
            _startDate, _selectedDateForDelivery, _minutesFromPickupSlot, parId)
        .map((item) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          selected: _selectedDeliverySlot == item,
          label: Column(
            children: [
              Text(
                item.formattedTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Available Slots ${item.availableSlots}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onSelected: (_) {
            setState(() {
              _selectedDeliverySlot = item;
            });
          },
        ),
      );
    }).toList();
  }

  // static int x = 0;
  void _saveCallback() async {
    bool isOneTimee;
    if (tempNode is MultiServiceModel) {
      MultiServiceModel a = tempNode as MultiServiceModel;
      isOneTimee = a.isOneTimeService;
    } else if (tempNode is SingleServiceModel) {
      SingleServiceModel a = tempNode as SingleServiceModel;
      isOneTimee = a.isOneTimeService;
    }
    if (isOneTimee) {
      if (_selectedSlot.availableSlots == 0) {
        await Fluttertoast.showToast(
          msg: "Not Available",
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }
    } else if (!isOneTimee) {
      if (_selectedSlot.availableSlots == 0 ||
          _selectedDeliverySlot.availableSlots == 0) {
        await Fluttertoast.showToast(
          msg: "Not Available",
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }
    }
    var svcIds = Provider.of<ServiceIds>(context, listen: false);
    int x = svcIds.parentCount;
    int parlen = svcIds.parentId.length;
    String parId = svcIds.parentId[x];
    svcIds.updateselectedAvailable(parId, _selectedSlot);
    svcIds.updatedeliveryAvailable(parId, _selectedDeliverySlot);

    if (x >= parlen - 1) {
      String currentparId = svcIds.parentId[x];
      Map<String, OrderTimeHandling> mapOfParentIdsForSlots = {};
      OrderTimeHandling pickupObj =
          OrderTimeHandling(_selectedDate, _selectedSlot);
      OrderTimeHandling deliveryObj = OrderTimeHandling(
          _selectedDateForDelivery, _selectedDeliverySlot);

      mapOfParentIdsForSlots['pickup'] = pickupObj;
      bool isOneTime;
      if (tempNode is MultiServiceModel) {
        MultiServiceModel a = tempNode as MultiServiceModel;
        isOneTime = a.isOneTimeService;
      } else if (tempNode is SingleServiceModel) {
        SingleServiceModel a = tempNode as SingleServiceModel;
        isOneTime = a.isOneTimeService;
      }

      if (!isOneTime) {
        mapOfParentIdsForSlots['delivery'] = deliveryObj;
      }

      svcIds.updateMapOfParentIdsForSlots(currentparId, mapOfParentIdsForSlots);
      Navigator.of(context).pushNamed(PaymentScreen.routeName);
      return;
    }

    String currentparId = svcIds.parentId[x];
    Map<String, OrderTimeHandling> mapOfParentIdsForSlots = {};
    OrderTimeHandling pickupObj =
        OrderTimeHandling(_selectedDate, _selectedSlot);
    OrderTimeHandling deliveryObj =
        OrderTimeHandling(_selectedDateForDelivery, _selectedDeliverySlot);

    mapOfParentIdsForSlots['pickup'] = pickupObj;
    bool isOneTime;
    if (tempNode is MultiServiceModel) {
      MultiServiceModel a = tempNode as MultiServiceModel;
      isOneTime = a.isOneTimeService;
    } else if (tempNode is SingleServiceModel) {
      SingleServiceModel a = tempNode as SingleServiceModel;
      isOneTime = a.isOneTimeService;
    }
    if (!isOneTime) {
      mapOfParentIdsForSlots['delivery'] = deliveryObj;
    }

    svcIds.updateMapOfParentIdsForSlots(currentparId, mapOfParentIdsForSlots);

    Provider.of<Orders>(context, listen: false).addPickupToCurrentOrder(
      OrderTimeHandling(
        _selectedDate,
        _selectedSlot,
      ),
    );
    svcIds.updateParentCount(x + 1);
    Navigator.of(context).pushNamed(PickupSelectScreen.routeName);
  }
}
