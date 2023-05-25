// import 'dart:core';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:washry/domain/delivery_slot_item.dart';
// import 'package:washry/domain/order_item.dart';
// import 'package:washry/application/cart.dart';
// import 'package:washry/application/delivery.dart';
// import 'package:washry/application/orders.dart';
// import 'package:washry/application/serviceIds.dart';
// import 'package:washry/application/services.dart';
// import 'package:washry/pages/payment/payment_screen.dart';

// class DeliverySelectScreen extends StatefulWidget {
//   static const routeName = "Delivery-Select-Screen";

//   @override
//   _DeliverySelectScreenState createState() => _DeliverySelectScreenState();
// }

// class _DeliverySelectScreenState extends State<DeliverySelectScreen> {
//   List<DateTime> _deliveryDates;
//   DateTime _selectedDate;
//   DeliverySlotItem _selectedSlot;
//   DateTime _startDate; // Format XX:XX
//   int _minutesFromPickupSlot;

//   Widget get _appBar => AppBar(
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.done),
//             onPressed: _saveCallback,
//           )
//         ],
//         title: Text('Delivery Slot'),
//       );

//   @override
//   void initState() {
//     super.initState();
//     _setInitialSelection();
//   }

//   /*
//     Find minimum time in minutes by adding pickup slot time and
//     and minimum service time.
//     Eg Pickup slot time is 13:21 and minimum service time in minutes is 20
//     so minimum time is 13:41 which is added to pickup date to find delivery date
//   */
//   int _getMinimumDeliveryTimeFrom(String pickupTime) {
//     final serviceData = Provider.of<Services>(context, listen: false);
//     int maxDeliveryTime = 0;
//     Provider.of<Cart>(context, listen: false).items.keys.forEach((item) {
//       int time = serviceData.getMinServiceTime(item);
//       if (time > maxDeliveryTime) maxDeliveryTime = time;
//     });
//     //time format XX:XX
//     maxDeliveryTime *= 60;
//     maxDeliveryTime += int.parse(pickupTime.substring(0, 2)) * 60;
//     maxDeliveryTime += int.parse(pickupTime.substring(3, 5));
//     return maxDeliveryTime;
//   }

//   void _setInitialSelection() {
//      final svcIds = Provider.of<ServiceIds>(context);
//     int x = svcIds.parlen;
//     String parId = svcIds.parentIds[x];
//     final deliveryData = Provider.of<Delivery>(context, listen: false);
//     final orderData = Provider.of<Orders>(context, listen: false);
//     //Get the start date which is pickup date
//     _startDate = orderData.getCurrentOrderPickup().expected;
//     _minutesFromPickupSlot = _getMinimumDeliveryTimeFrom(
//         orderData.getCurrentOrderPickup().timeSlot.from);

//     _deliveryDates =
//         deliveryData.getDeliveryDatesFrom(_startDate, _minutesFromPickupSlot);

//     _selectedDate = _deliveryDates[0];

//     _selectedSlot = deliveryData.getDeliverySlotsFor(
//         _startDate, _selectedDate, _minutesFromPickupSlot,parId)[0];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deliveryData = Provider.of<Delivery>(context, listen: false);
//     return SafeArea(
//       child: Scaffold(
//         appBar: _appBar,
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               ListTile(title: Text('Select Delivery Date')),
//               SizedBox(height: 50, child: _getDateList(deliveryData)),
//               Divider(),
//               ListTile(title: Text('Select Delivery Slot')),
//               Align(
//                 alignment: Alignment.center,
//                 child: Wrap(
//                     direction: Axis.horizontal,
//                     children: _getSlotsList(deliveryData)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _getDateList(Delivery deliveryData) => ListView(
//         scrollDirection: Axis.horizontal,
//         children: _deliveryDates
//             .map((item) => Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ChoiceChip(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5)),
//                     label: Text(
//                       _getFormattedDate(item),
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     selected: _selectedDate == item,
//                     onSelected: (_) {
//                       setState(() {
//                         final svcIds = Provider.of<ServiceIds>(context);
//                         int x = svcIds.parlen;
//                         String parId = svcIds.parentIds[x];
//                         _selectedDate = item;
//                         _selectedSlot = deliveryData.getPickupSlotsFor(
//                             _selectedDate, parId)[0];
//                       });
//                     },
//                   ),
//                 ))
//             .toList(),
//       );

//   List<Widget> _getSlotsList(Delivery deliveryData) {
//      final svcIds = Provider.of<ServiceIds>(context);
//     int x = svcIds.parlen;
//     String parId = svcIds.parentIds[x];
//     return deliveryData
//           .getDeliverySlotsFor(
//               _startDate, _selectedDate, _minutesFromPickupSlot,parId)
//           .map((item) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ChoiceChip(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//             selected: _selectedSlot == item,
//             label: Text(
//               item.formattedTime,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             onSelected: (_) {
//               setState(() {
//                 _selectedSlot = item;
//               });
//             },
//           ),
//         );
//       }).toList();}

//   String _getFormattedDate(DateTime orderTime) {
//     var today = DateTime.now();
//     if (orderTime.day == today.day &&
//         orderTime.month == today.month &&
//         orderTime.year == today.year) {
//       return 'Today, ' + DateFormat.MMMd().format(orderTime).toString();
//     } else if (orderTime.day == today.day + 1 &&
//         orderTime.month == today.month &&
//         orderTime.year == today.year) {
//       return 'Tomorrow, ' + DateFormat.MMMd().format(orderTime).toString();
//     } else {
//       return DateFormat("EEEE, MMM d").format(orderTime).toString();
//     }
//   }

//   void _saveCallback() {
//     Provider.of<Orders>(context, listen: false).addDeliveryToCurrentOrder(
//       OrderTimeHandling(_selectedDate, _selectedSlot),
//     );
//     Navigator.of(context).pushNamed(PaymentScreen.routeName);
//   }
// }
