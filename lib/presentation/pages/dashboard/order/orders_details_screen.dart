// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:washry/domain/order_item.dart';
// import 'package:washry/application/cart.dart';
// import 'package:washry/application/serviceIds.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   static const routeName = 'Order-Details-Screen';

//   @override
//   _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   OrderItem _item;
//   bool init = true;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (init) {
//       init = false;
//       this._item = ModalRoute.of(context).settings.arguments;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//      final cartData = Provider.of<Cart>(context, listen: false);
//     final svcIds = Provider.of<ServiceIds>(context);
//     int deliveryCharge = 0;
//     cartData.deliveryChargesMap.forEach((key, value) {
//       bool isPresent = false;
//       svcIds.parentIds.forEach((element) {
//         if (element == key) {
//           isPresent = true;
//         }
//       });
//       if (isPresent) {
//         deliveryCharge += value;
//       }

      

//     });
//     final theme = Theme.of(context);
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Order Details'),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       SelectableText(
//                         'OrderId:-',
//                         style: theme.textTheme.titleLarge,
//                       ),
//                       Spacer(),
//                       SelectableText(
//                         _item.id,
//                         style: theme.textTheme.titleLarge,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (true
//                 // _item.orderStatus != OrderStatus.Cancelled
//                 )
//                 Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: <Widget>[
//                             _item.orderStatus.index >=
//                                     OrderStatus.PickedUp.index
//                                 ? Text(
//                                     "Picked Up",
//                                     style: theme.textTheme.bodySmall
//                                         .copyWith(fontSize: 14),
//                                   )
//                                 : Text(
//                                     "Pick up",
//                                     style: theme.textTheme.bodySmall
//                                         .copyWith(fontSize: 14),
//                                   ),
//                             Spacer(),
//                             _item.orderStatus == OrderStatus.Completed
//                                 ? Text(
//                                     "Delivered",
//                                     style: theme.textTheme.bodySmall
//                                         .copyWith(fontSize: 14),
//                                   )
//                                 : Text(
//                                     "Delivery",
//                                     style: theme.textTheme.bodySmall
//                                         .copyWith(fontSize: 14),
//                                   ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Row(
//                           children: <Widget>[
//                             _item.orderStatus.index >=
//                                     OrderStatus.PickedUp.index
//                                 ? Text(
//                                     _getOrderDate(_item.pickup.actual),
//                                     style: theme.textTheme.titleLarge
//                                         .copyWith(fontSize: 16),
//                                   )
//                                 : Text(
//                                     _getOrderDate(_item.pickup.expected),
//                                     style: theme.textTheme.titleLarge
//                                         .copyWith(fontSize: 16),
//                                   ),
//                             Spacer(),
//                             _item.orderStatus == OrderStatus.Completed
//                                 ? Text(
//                                     _getOrderDate(_item.delivery.actual),
//                                     style: theme.textTheme.titleLarge
//                                         .copyWith(fontSize: 16),
//                                   )
//                                 : Text(
//                                     _getOrderDate(_item.delivery.expected),
//                                     style: theme.textTheme.titleLarge
//                                         .copyWith(fontSize: 16),
//                                   ),
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: <Widget>[
//                             Text(_item.pickup.timeSlot.formattedTime),
//                             Spacer(),
//                             Text(_item.delivery.timeSlot.formattedTime),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Text(
//                           'Your Address',
//                           style: theme.textTheme.bodySmall.copyWith(fontSize: 14),
//                         ),
//                         SizedBox(height: 10),
//                         SelectableText(
//                           _item.address.formattedAddress,
//                           style:
//                               theme.textTheme.titleLarge.copyWith(fontSize: 16),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               SizedBox(height: 5),
//               Container(
//                 height: min(_item.items.length * 100.toDouble(), 250),
//                 child: Card(
//                     child: Scrollbar(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: DataTable(
//                         headingRowHeight: 30,
//                         columnSpacing: 20,
//                         dataRowHeight: 60,
//                         columns: [
//                           DataColumn(label: Text('Qty')),
//                           DataColumn(label: Text('Product Name')),
//                           DataColumn(label: Text('Service')),
//                           DataColumn(label: Text('Amount')),
//                         ],
//                         rows: _item.items.map((item) {
//                           return DataRow(cells: [
//                             DataCell(Text(item.quantity.toString())),
//                             DataCell(
//                               Container(
//                                 child: Text(
//                                     item.title + ' (${item.categoryName})'),
//                                 width: 150,
//                               ),
//                             ),
//                             DataCell(Text(item.serviceName)),
//                             DataCell(Text('Rs ' +
//                                 (item.price * item.quantity)
//                                     .toStringAsFixed(0)
//                                     .toString())),
//                           ]);
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 )),
//               ),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text('Payments',
//                           style:
//                               theme.textTheme.bodySmall.copyWith(fontSize: 14)),
//                       SizedBox(height: 5),
//                       Row(
//                         children: <Widget>[
//                           Text('Subtotal',
//                               style: theme.textTheme.bodySmall
//                                   .copyWith(fontSize: 14)),
//                           Spacer(),
//                           Text('Rs ' + _item.amount.subtotal.toString(),
//                               style: theme.textTheme.titleLarge
//                                   .copyWith(fontSize: 16)),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       Row(
//                         children: <Widget>[
//                           Text('Service Charges',
//                               style: theme.textTheme.bodySmall
//                                   .copyWith(fontSize: 14)),
//                           Spacer(),
//                           Text('Rs ' + deliveryCharge.toString(),
//                               style: theme.textTheme.titleLarge
//                                   .copyWith(fontSize: 16)),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       Row(
//                         children: <Widget>[
//                           Text('Discount',
//                               style: theme.textTheme.bodySmall
//                                   .copyWith(fontSize: 14)),
//                           Spacer(),
//                           Text('Rs ' + _item.amount.discount.toString(),
//                               style: theme.textTheme.titleLarge
//                                   .copyWith(fontSize: 16)),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: <Widget>[
//                           Text(
//                               _item.hasPaid
//                                   ? 'Amount paid via ' + _item.paymentMethod
//                                   : 'To Be Paid via ' + _item.paymentMethod,
//                               style: theme.textTheme.titleLarge.copyWith(
//                                   fontSize: 16, color: theme.primaryColor)),
//                           Spacer(),
//                           Text(
//                             'Rs ' +
//                                 (_item.amount.subtotal +
//                                         deliveryCharge -
//                                         _item.amount.discount)
//                                     .toString(),
//                             style: theme.textTheme.titleLarge.copyWith(
//                                 fontSize: 16, color: theme.primaryColor),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getOrderDate(DateTime orderTime) {
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
// }
