import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dotted_line/dotted_line.dart';

import '../../../domain/order_item.dart';
import '../../../domain/transaction.dart';
import '../../../domain/transaction_history.dart';
import '../../../core/network/url.dart';
import '../../../application/orders.dart';
import '../../../presentation/pages/dashboard/order/order_details_screen.dart';

class OrderListItem extends StatefulWidget {
  final OrderItem item;

  const OrderListItem(this.item, {Key key}) : super(key: key);

  @override
  OrderListItemState createState() => OrderListItemState();
}

class OrderListItemState extends State<OrderListItem> {
  bool loading = false;

  num getTotalAmount() {
    num totalAmount = 0;

    widget.item.categoryItems.values.toList().forEach((categoryItem) {
      totalAmount += categoryItem.categoryAmount.delivery +
          categoryItem.categoryAmount.subtotal -
          categoryItem.categoryAmount.discount;
    });
    totalAmount += widget.item.totalAmount.tip;
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    bool isPending = true;
   
    widget.item.categoryItems.forEach((key, value) {
      if (value.serviceStatus != ServiceStatus.Pending) {
        isPending = false;
      }
    });
    num totalAmount = getTotalAmount();
    var theme = Theme.of(context);
    var mediaQuery = MediaQuery.of(context).size;
    List<String> orderServicesName = [];
    widget.item.categoryItems.values.toList().forEach((element) {
      orderServicesName.add(element.parentName);
    });
    return loading
        ? const LinearProgressIndicator()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              onTap: () => {
                Navigator.of(context).pushNamed(OrderDetailsScreen.routeName,
                    arguments: widget.item),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: mediaQuery.height * 0.015),
                  Row(
                    children: [
                      Text(
                        'Order Id: ${widget.item.id}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (isPending)
                        TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _showCancelAlert,
                          child: const Text('Cancel'),
                        ),
                     
                    ],
                  ),
                  Text(widget.item.address.title),
                  const SizedBox(height: 10),
                  Text('₹$totalAmount'),
                  const SizedBox(height: 5),
                  const DottedLine(
                    direction: Axis.horizontal,
                    lineLength: double.infinity,
                    dashLength: 4.0,
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    children: orderServicesName
                        .map((e) => Text('$e   '))
                        .toList(),
                  ),
                  Text(
                    DateFormat.yMMMd()
                        .format(widget.item.orderTime)
                        .toString(),
                    style: theme.textTheme.bodySmall.copyWith(fontSize: 13),
                  ),
                  Text(
                    DateFormat("hh:mm a")
                        .format(widget.item.orderTime)
                        .toString(),
                    style: theme.textTheme.bodySmall.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  const Divider(thickness: 2, color: Colors.black)
                ],
              ),
            ),
          );
  }

  void _showCancelAlert() async {
    final wannaDel = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Alert'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (!wannaDel) return;
    setState(() {
      loading = true;
    });
    try {
      await Provider.of<Orders>(context, listen: false)
          .cancelOrder(widget.item);
      String auth;
      FirebaseAuth.instance.authStateChanges().listen((event) async {
        if (event != null) {
          auth = await event.getIdToken();

          final url =
              '${URL.ORDERS_DATABASE_URL}/${widget.item.id}.json?auth=$auth';
          final response = await http.patch(Uri.parse(url),
              body: jsonEncode(widget.item.toJson()));
          final responseData = json.decode(response.body);
          String paymentMode = responseData['payment']['paymentMode'];
          if (paymentMode == 'Washry Wallet') {
            double total = 0;
            responseData['totalAmount'].forEach((key, val) {
              if (key != 'discount') {
                total += val;
              } else {
                total -= val;
              }
            });
            double prevWallet = 0;
            double prevWalletCoins = 0.0;
            final userId = FirebaseAuth.instance.currentUser.uid;
            try {
              final transUrl = "${URL.TRANSACTION_URL}/$userId.json";
              final res = await http.get(Uri.parse(transUrl));
              final responseData = jsonDecode(res.body) as Map<String, dynamic>;
              prevWallet = responseData["walletMoney"] ?? 0.0;
              if (responseData["walletCoins"] != null) {
                prevWalletCoins = responseData["walletCoins"] * 1.0;
              }
            } catch (e) {if (kDebugMode) {
              print(e);
            }}

            final url = "${URL.TRANSACTION_URL}/$userId.json";
            final urll =
                "${URL.TRANSACTION_URL}/$userId/transHistory.json";
            MoneyTransaction transaction = MoneyTransaction();
            transaction.walletMoney = total + prevWallet;
            transaction.walletCoins = prevWalletCoins;
            TransactionHistory transactionHistory = TransactionHistory();
            transactionHistory.date = DateTime.now();
            transactionHistory.amount = total;
            transactionHistory.orderId = widget.item.id;
            transactionHistory.credit = true;
            transactionHistory.debit = false;
            transactionHistory.title = "Refunded for order cancellation";
            log('wha ${transaction.walletMoney}');
            // transaction.transactionHistory = transactionHistory;
            await http.patch(Uri.parse(url),
                body: jsonEncode(transaction.toJson()));
            final result = await http.post(Uri.parse(urll),
                body: jsonEncode(transactionHistory.toJson()));
            log(result.toString());
          }
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order Cancelled Successfully'),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel this order'),
        ),
      );
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text('Could not cancel this order'),
      // ));
    }
  }

  //

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
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  // Widget _getStatus(OrderStatus item) {
  //   switch (item) {
  //     case OrderStatus.Pending:
  //       return statusWidget('PENDING', Colors.grey);
  //     case OrderStatus.Accepted:
  //       return statusWidget('ACCEPTED', Colors.blue);
  //     case OrderStatus.PickedUp:
  //       return statusWidget('PICKED UP', Colors.yellow);
  //     case OrderStatus.Completed:
  //       return statusWidget('COMPLETED', Colors.green);
  //     case OrderStatus.Cancelled:
  //       return statusWidget('CANCELLED', Colors.red);
  //   }
  // }
}
