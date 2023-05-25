import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../domain/order_item.dart';
import '../../../../presentation/pages/dashboard/order/suborder_details_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const routeName = 'Order-Details-Screen';

  const OrderDetailsScreen({Key key}) : super(key: key);

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderItem _item;
  bool init = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      init = false;
      _item = ModalRoute.of(context).settings.arguments;
    }
  }

  Widget statusWidget(String status, Color color) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: null,
      child: Text(
        status,
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }

  TextStyle getTextStyle(Color fontColor, double fontSize, FontWeight weight) {
    return GoogleFonts.poppins(
      fontWeight: weight,
      color: fontColor,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    var totalAmount = _item.totalAmount;
    final theme = Theme.of(context);
    final List<BoxShadow> boxShadows = [
      BoxShadow(
        offset: const Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 1,
        color: Colors.lightBlue.withOpacity(0.3),
      )
    ];
    String getDiscountInfo() {
      String promoType;
      if (_item.totalAmount.discount != 0) {
        promoType = _item.promoCodeId;
      } else if (_item.totalAmount.discount != 0 && _item.promoCodeId == null) {
        promoType = 'Washry Coins';
      } else {
        promoType = ' ';
      }
      return promoType;
    }

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _item.categoryItems.keys.toList().length > 1
                    ? MultipleOrderPage(_item)
                    : SingleOrderPage(_item),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[900],
                      width: 2,
                    ),
                    boxShadow: boxShadows,
                  ),
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Payments',
                        style: getTextStyle(Colors.black, 17, FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Text('Subtotal',
                              style: theme.textTheme.bodySmall
                                  .copyWith(fontSize: 14)),
                          const Spacer(),
                          Text('Rs ${totalAmount.subtotal}',
                              style: theme.textTheme.titleLarge
                                  .copyWith(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Text('Service Charges',
                              style: theme.textTheme.bodySmall
                                  .copyWith(fontSize: 14)),
                          const Spacer(),
                          Text('Rs ${totalAmount.delivery}',
                              style: theme.textTheme.titleLarge
                                  .copyWith(fontSize: 16)),
                        ],
                      ),
                      // SizedBox(height: 5),
                      _item.totalAmount.discount == 0
                          ? const SizedBox()
                          : Row(
                              children: <Widget>[
                                Text('Discount (${getDiscountInfo()})',
                                    style: theme.textTheme.bodySmall
                                        .copyWith(fontSize: 14)),
                                const Spacer(),
                                Text('Rs ${totalAmount.discount}',
                                    style: theme.textTheme.titleLarge
                                        .copyWith(fontSize: 16)),
                              ],
                            ),
                      const SizedBox(height: 5),
                      _item.totalAmount.tip == 0
                          ? const SizedBox()
                          : Row(
                              children: <Widget>[
                                Text('Tip ',
                                    style: theme.textTheme.bodySmall
                                        .copyWith(fontSize: 14)),
                                const Spacer(),
                                Text('Rs ${_item.totalAmount.tip}',
                                    style: theme.textTheme.titleLarge
                                        .copyWith(fontSize: 16)),
                              ],
                            ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          grandTotalWidget(theme),
                          const Spacer(),
                          Text(
                            'Rs ${totalAmount.subtotal + totalAmount.delivery - totalAmount.discount + totalAmount.tip}',
                            style: theme.textTheme.titleLarge.copyWith(
                                fontSize: 16, color: theme.primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget grandTotalWidget(ThemeData theme) {
    String paymentMode = _item.payment['paymentMode'];
    bool isPaid = false;
    _item.categoryItems.forEach((key, value) {
      if (value.serviceStatus.index > 1 &&
          value.serviceStatus != ServiceStatus.Cancelled) {
        isPaid = true;
      }
    });
    if (_item.hasPaid) {
      return Row(
        children: [
          Text('Grand Total ',
              style: theme.textTheme.titleLarge
                  .copyWith(fontSize: 16, color: theme.primaryColor)),
          Text('(Paid By $paymentMode)',
              style: theme.textTheme.titleLarge
                  .copyWith(fontSize: 14, color: theme.primaryColor)),
        ],
      );
    } else {
      if (!isPaid) {
        return Text('Grand Total (To Pay Cash)',
            style: theme.textTheme.titleLarge
                .copyWith(fontSize: 16, color: theme.primaryColor));
      } else {
        return Text('Grand Total (Paid Via Cash)',
            style: theme.textTheme.titleLarge
                .copyWith(fontSize: 16, color: theme.primaryColor));
      }
    }
  }
}

// ignore: must_be_immutable
class MultipleOrderPage extends StatelessWidget {
  final OrderItem _item;
  MultipleOrderPage(this._item, {Key key}) : super(key: key);
  final List<BoxShadow> boxShadows = [
    BoxShadow(
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 1,
      color: Colors.lightBlue.withOpacity(0.3),
    )
  ];
  TextStyle getTextStyle(Color fontColor, double fontSize, FontWeight weight) {
    return GoogleFonts.poppins(
      fontWeight: weight,
      color: fontColor,
      fontSize: fontSize,
    );
  }

  List<String> active = [];
  List<String> completed = [];
  List<String> cancelled = [];

  int flag = 0;
  @override
  Widget build(BuildContext context) {
    if (flag == 0) {
      _item.categoryItems.forEach((key, value) {
        if (value.serviceStatus.index <= 2) {
          active.add(key);
        } else if (value.serviceStatus.index == 3) {
          completed.add(key);
        } else if (value.serviceStatus.index == 4) {
          cancelled.add(key);
        }
      });
      flag = 1;
    }

    // OrderAmount totalAmount = _item.totalAmount;
    final theme = Theme.of(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue[900],
                width: 2,
              ),
              boxShadow: boxShadows,
            ),
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Name: ',
                      style: getTextStyle(Colors.grey, 14, FontWeight.w500),
                    ),
                    Text(
                      ' ${_item.address.contactName}',
                      style: getTextStyle(Colors.black, 14, FontWeight.w600),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Address: ',
                          style:
                              getTextStyle(Colors.grey, 14, FontWeight.w500)),
                      Text(
                        ' ${_item.address.formattedAddress}',
                        style: getTextStyle(Colors.black, 14, FontWeight.w500),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.01),
          DefaultTabController(
            initialIndex: 0,
            length: 3,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 3),
                  height:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.06
                          : MediaQuery.of(context).size.height * 0.13,
                  child: TabBar(
                    indicator: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      Container(child: getServicesListWidget(theme, active)),
                      Container(child: getServicesListWidget(theme, completed)),
                      Container(child: getServicesListWidget(theme, cancelled)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget grandTotalWidget(ThemeData theme) {
  //   String paymentMode = _item.payment['paymentMode'];
  //   if (_item.hasPaid) {
  //     return Text('Grand Total (Paid By $paymentMode)',
  //         style: theme.textTheme.titleLarge
  //             .copyWith(fontSize: 16, color: theme.primaryColor));
  //   } else {
  //     if (_item.orderStatus.index <= 5)
  //       return Text('Grand Total (To Pay Cash)',
  //           style: theme.textTheme.titleLarge
  //               .copyWith(fontSize: 16, color: theme.primaryColor));
  //     else if (_item.orderStatus.index == 6)
  //       return Text('Grand Total (Paid Via Cash)',
  //           style: theme.textTheme.titleLarge
  //               .copyWith(fontSize: 16, color: theme.primaryColor));
  //     else
  //       return Text('Grand Total (After Cancellation)',
  //           style: theme.textTheme.titleLarge
  //               .copyWith(fontSize: 16, color: theme.primaryColor));
  //   }
  // }

  Widget getServicesListWidget(ThemeData theme, List<String> servicesList) {
    return servicesList.isNotEmpty
        ? ListView.builder(
            itemBuilder: (BuildContext context, int i) {
              var parentId = servicesList[i];
              //var services = Provider.of<Services>(context);
              String parentName = _item.categoryItems[parentId].parentName;

              return GestureDetector(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(parentName,
                          style:
                              getTextStyle(Colors.black, 16, FontWeight.w600)),
                      const Spacer(),
                      _getStatus(_item.categoryItems[parentId].serviceStatus),
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuborderDetailsScreen(
                              _item.categoryItems[parentId],
                              parentId,
                              theme,
                            ))),
              );
            },
            itemCount: servicesList.length,
          )
        : Container(
            alignment: Alignment.center,
            child: const Text(
              "No Services Here!!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
  }

  // Widget getTimingCard(bool isOneTime, String parentId) {
  //   OrderTimeHandling pickup = _item.categoryItems[parentId].pickup;
  //   OrderTimeHandling delivery = _item.categoryItems[parentId].delivery ?? null;
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
  //     child: Card(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 isOneTime
  //                     ? Text(
  //                         'Arrival Time: ',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       )
  //                     : Text(
  //                         'Pickup Time: ',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                 Text('${pickup.timeSlot.from} - ${pickup.timeSlot.to}'),
  //                 Text(
  //                     ',  ${pickup.expected.day}-${pickup.expected.month}-${pickup.expected.year}')
  //               ],
  //             ),
  //             SizedBox(height: 5),
  //             !isOneTime
  //                 ? Row(
  //                     children: [
  //                       Text(
  //                         'Delivery Time: ',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       Text(
  //                           '${delivery.timeSlot.from} - ${delivery.timeSlot.to}'),
  //                       Text(
  //                           ',  ${delivery.expected.day}-${delivery.expected.month}-${delivery.expected.year}')
  //                     ],
  //                   )
  //                 : Container()
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  _getStatus(ServiceStatus item) {
    switch (item) {
      case ServiceStatus.Pending:
        return statusWidget('PENDING', Colors.white);
      case ServiceStatus.Accepted:
        return statusWidget('ACCEPTED', Colors.white);
      case ServiceStatus.In_Process:
        return statusWidget('IN PROCESS', Colors.white);
      case ServiceStatus.Completed:
        return statusWidget('COMPLETED', Colors.white);
      case ServiceStatus.Cancelled:
        return statusWidget('CANCELLED', Colors.white);
    }
  }

  Widget statusWidget(String status, Color color) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: null,
      child: Text(
        status,
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }
}

// ignore: must_be_immutable
class SingleOrderPage extends StatefulWidget {
  final OrderItem _item;
  const SingleOrderPage(this._item, {Key key}) : super(key: key);

  @override
  SingleOrderPageState createState() => SingleOrderPageState();
}

class SingleOrderPageState extends State<SingleOrderPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String parentId = widget._item.categoryItems.keys.toList()[0];
    CategoryItems item = widget._item.categoryItems[parentId];
    bool isOneTime;
    if (item.delivery != null) {
      isOneTime = false;
    } else {
      isOneTime = true;
    }
    return Column(
      children: [
        Card(
          child: Container(
            padding: const EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Text(
                  "Status: ",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(width: 10),
                _getStatus(item.serviceStatus)
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    item.serviceStatus.index >=
                                ServiceStatus.In_Process.index &&
                            item.serviceStatus != ServiceStatus.Cancelled
                        ? Text(
                            isOneTime ? 'Arrived' : "Picked Up",
                            style: theme.textTheme.bodySmall
                                .copyWith(fontSize: 14),
                          )
                        : Text(
                            isOneTime ? 'Arrival Time' : "Pick up",
                            style: theme.textTheme.bodySmall
                                .copyWith(fontSize: 14),
                          ),
                    const Spacer(),
                    isOneTime
                        ? Container()
                        : item.serviceStatus == ServiceStatus.Completed
                            ? Text(
                                "Delivered",
                                style: theme.textTheme.bodySmall
                                    .copyWith(fontSize: 14),
                              )
                            : Text(
                                "Delivery",
                                style: theme.textTheme.bodySmall
                                    .copyWith(fontSize: 14),
                              ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    item.serviceStatus.index >=
                                ServiceStatus.In_Process.index &&
                            item.serviceStatus != ServiceStatus.Cancelled
                        ? Text(
                            _getOrderDate(item.pickup.actual),
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16),
                          )
                        : Text(
                            _getOrderDate(item.pickup.expected),
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16),
                          ),
                    const Spacer(),
                    isOneTime
                        ? Container()
                        : item.serviceStatus == ServiceStatus.Completed
                            ? Text(
                                _getOrderDate(item.delivery.actual),
                                style: theme.textTheme.titleLarge
                                    .copyWith(fontSize: 16),
                              )
                            : Text(
                                _getOrderDate(item.delivery.expected),
                                style: theme.textTheme.titleLarge
                                    .copyWith(fontSize: 16),
                              ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Text(item.pickup.timeSlot.formattedTime),
                    const Spacer(),
                    isOneTime
                        ? Container()
                        : Text(item.delivery.timeSlot.formattedTime),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Address',
                  style: theme.textTheme.bodySmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  widget._item.address.formattedAddress,
                  style: theme.textTheme.titleLarge.copyWith(fontSize: 16),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: min(item.items.length * 100.toDouble(), 250),
          width: MediaQuery.of(context).size.width * 0.99,
          child: Row(
            children: [
              Expanded(
                child: Card(
                    child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowHeight: 30,
                        columnSpacing: 20,
                        dataRowHeight: 60,
                        columns: const [
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Product Name')),
                          DataColumn(label: Text('Service')),
                          DataColumn(label: Text('Amount')),
                        ],
                        rows: item.items.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item.quantity.toString())),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                    '${item.title} (${item.categoryName})'),
                              ),
                            ),
                            DataCell(Text(item.serviceName)),
                            DataCell(Text(
                                'Rs ${(item.price * item.quantity).toStringAsFixed(0)}')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                )),
              ),
              const SizedBox()
            ],
          ),
        ),
        // Card(
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: <Widget>[
        //         Text('Payments',
        //             style: theme.textTheme.bodySmall.copyWith(fontSize: 14)),
        //         SizedBox(height: 5),
        //         Row(
        //           children: <Widget>[
        //             Text('Subtotal',
        //                 style: theme.textTheme.bodySmall.copyWith(fontSize: 14)),
        //             Spacer(),
        //             Text('Rs ' + widget._item.totalAmount.subtotal.toString(),
        //                 style:
        //                     theme.textTheme.titleLarge.copyWith(fontSize: 16)),
        //           ],
        //         ),
        //         SizedBox(height: 5),
        //         Row(
        //           children: <Widget>[
        //             Text('Service Charges',
        //                 style: theme.textTheme.bodySmall.copyWith(fontSize: 14)),
        //             Spacer(),
        //             Text('Rs ' + item.categoryAmount.delivery.toString(),
        //                 style:
        //                     theme.textTheme.titleLarge.copyWith(fontSize: 16)),
        //           ],
        //         ),
        //         SizedBox(height: 5),
        //         Row(
        //           children: <Widget>[
        //             Text('Discount',
        //                 style: theme.textTheme.bodySmall.copyWith(fontSize: 14)),
        //             Spacer(),
        //             Text('Rs ' + item.categoryAmount.discount.toString(),
        //                 style:
        //                     theme.textTheme.titleLarge.copyWith(fontSize: 16)),
        //           ],
        //         ),
        //         SizedBox(height: 10),
        //         Row(
        //           children: <Widget>[
        //             Text(
        //                 widget._item.hasPaid
        //                     ? 'Amount paid via ' +
        //                         widget._item.payment['paymentMode']
        //                     : 'To Be Paid via ' +
        //                         widget._item.payment['paymentMode'],
        //                 style: theme.textTheme.titleLarge
        //                     .copyWith(fontSize: 16, color: theme.primaryColor)),
        //             Spacer(),
        //             Text(
        //               'Rs ' +
        //                   (item.categoryAmount.subtotal +
        //                           item.categoryAmount.delivery -
        //                           item.categoryAmount.discount)
        //                       .toString(),
        //               style: theme.textTheme.titleLarge
        //                   .copyWith(fontSize: 16, color: theme.primaryColor),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }

  // ignore: missing_return
  Widget _getStatus(ServiceStatus item) {
    switch (item) {
      case ServiceStatus.Pending:
        return statusWidget('PENDING', Colors.white);
      case ServiceStatus.Accepted:
        return statusWidget('ACCEPTED', Colors.white);
      case ServiceStatus.In_Process:
        return statusWidget('IN PROCESS', Colors.white);
      case ServiceStatus.Completed:
        return statusWidget('COMPLETED', Colors.white);
      case ServiceStatus.Cancelled:
        return statusWidget('CANCELLED', Colors.white);
    }
  }

  Widget statusWidget(String status, Color color) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: null,
      child: Text(
        status,
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }

  String _getOrderDate(DateTime orderTime) {
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
}
