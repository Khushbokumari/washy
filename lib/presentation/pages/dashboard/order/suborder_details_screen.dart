// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:washry/domain/cart_model.dart';
import 'package:washry/domain/order_item.dart';

class SuborderDetailsScreen extends StatefulWidget {
  CategoryItems categoryItem;
  String parentId;
  ThemeData theme;
  SuborderDetailsScreen(this.categoryItem, this.parentId, this.theme, {Key key})
      : super(key: key);
  @override
  SuborderDetailsScreenState createState() => SuborderDetailsScreenState();
}

class SuborderDetailsScreenState extends State<SuborderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isOneTime;
    if (widget.categoryItem.delivery != null) {
      isOneTime = false;
    } else {
      isOneTime = true;
    }
    List<CartModel> list = widget.categoryItem.items;

    var subtotalByParent = widget.categoryItem.categoryAmount.subtotal;
    var deliveryByParent = widget.categoryItem.categoryAmount.delivery;
    var discountByParent = widget.categoryItem.categoryAmount.discount;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryItem.parentName),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
          child: SingleChildScrollView(
            child: Column(
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
                        _getStatus(widget.categoryItem.serviceStatus)
                      ],
                    ),
                  ),
                ),
                getTimingCard(isOneTime, widget.parentId, widget.theme),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  height: min(
                      widget.categoryItem.items.length * 100.toDouble(), 225),
                  width: double.infinity,
                  // 175,
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
                            DataColumn(label: Text('Item Name')),
                            DataColumn(label: Text('Service')),
                            DataColumn(label: Text('Amount')),
                          ],
                          rows: list.map((item) {
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
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text('Payments',
                        //     style: theme.textTheme.bodySmall
                        //         .copyWith(fontSize: 14)),
                        // SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Text('Subtotal',
                                style: widget.theme.textTheme.bodySmall
                                    .copyWith(fontSize: 14)),
                            const Spacer(),
                            Text('Rs $subtotalByParent',
                                style: widget.theme.textTheme.titleLarge
                                    .copyWith(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Text('Service Charges',
                                style: widget.theme.textTheme.bodySmall
                                    .copyWith(fontSize: 14)),
                            const Spacer(),
                            Text('Rs $deliveryByParent',
                                style: widget.theme.textTheme.titleLarge
                                    .copyWith(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        discountByParent != 0
                            ? Row(
                                children: <Widget>[
                                  Text('Discount',
                                      style: widget.theme.textTheme.bodySmall
                                          .copyWith(fontSize: 14)),
                                  const Spacer(),
                                  Text('Rs $discountByParent',
                                      style: widget.theme.textTheme.titleLarge
                                          .copyWith(fontSize: 16)),
                                ],
                              )
                            : const SizedBox(height: 10),
                        discountByParent != 0
                            ? const SizedBox(height: 10)
                            : const SizedBox(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Total',
                              style: widget.theme.textTheme.titleLarge.copyWith(
                                  fontSize: 14,
                                  color: widget.theme.primaryColor),
                            ),
                            const Spacer(),
                            Text(
                              'Rs ${subtotalByParent + deliveryByParent - discountByParent}',
                              style: widget.theme.textTheme.titleLarge.copyWith(
                                  fontSize: 14,
                                  color: widget.theme.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget getTimingCard(bool isOneTime, String parentId, ThemeData theme) {
    return Card(
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
                widget.categoryItem.serviceStatus.index >=
                            ServiceStatus.In_Process.index &&
                        widget.categoryItem.serviceStatus !=
                            ServiceStatus.Cancelled
                    ? Text(
                        isOneTime ? 'Arrived' : "Picked Up",
                        style: theme.textTheme.bodySmall.copyWith(fontSize: 14),
                      )
                    : Text(
                        isOneTime ? 'Arrival Time' : "Pick up",
                        style: theme.textTheme.bodySmall.copyWith(fontSize: 14),
                      ),
                const Spacer(),
                isOneTime
                    ? Container()
                    : widget.categoryItem.serviceStatus ==
                            ServiceStatus.Completed
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
                widget.categoryItem.serviceStatus.index >=
                            ServiceStatus.In_Process.index &&
                        widget.categoryItem.serviceStatus !=
                            ServiceStatus.Cancelled
                    ? Text(
                        _getOrderDate(widget.categoryItem.pickup.actual),
                        style:
                            theme.textTheme.titleLarge.copyWith(fontSize: 16),
                      )
                    : Text(
                        _getOrderDate(widget.categoryItem.pickup.expected),
                        style:
                            theme.textTheme.titleLarge.copyWith(fontSize: 16),
                      ),
                const Spacer(),
                isOneTime
                    ? Container()
                    : widget.categoryItem.serviceStatus ==
                            ServiceStatus.Completed
                        ? Text(
                            _getOrderDate(widget.categoryItem.delivery.actual),
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16),
                          )
                        : Text(
                            _getOrderDate(
                                widget.categoryItem.delivery.expected),
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16),
                          ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                Text(widget.categoryItem.pickup.timeSlot.formattedTime),
                const Spacer(),
                isOneTime
                    ? Container()
                    : Text(widget.categoryItem.delivery.timeSlot.formattedTime),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

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
