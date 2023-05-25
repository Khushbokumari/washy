import 'dart:developer' as lg;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/order_item.dart';
import '../../../../application/auth.dart';
import '../../../../application/orders.dart';
import '../../auth/not_logged_in_screen.dart';
import '../../../components/cart/cart_icon_button.dart';
import '../../../components/error_alert_dialog.dart';
import '../../../components/order/order_list_item.dart';
import '../../../components/shimmer_loading_list.dart';

class OrderScreen extends StatefulWidget {
  static const String routeName = 'Orders-Screen';

  const OrderScreen({Key key}) : super(key: key);

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  Future _ordersLoadFuture;
  List<int> avSlots = [];

  Widget _errorAlert(e) {
    return ErrorAlertDialog(
      onPressed: _resetFuture,
      title: "Error",
      content: 'No internet connection',
      actionTitle: 'Retry',
    );
  }

  void _resetFuture() {
    setState(() {
      _ordersLoadFuture =
          Provider.of<Orders>(context, listen: false).fetchAndSetOrders(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, authData, _) {
        return FutureBuilder<bool>(
          future: authData.isAuth(),
          builder: (ctx, snapshot1) {
            if (snapshot1.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return snapshot1.data
                  ? SafeArea(
                      child: Consumer<Orders>(
                        builder: (ctx, orderData, _) {
                          _ordersLoadFuture ??=
                              Provider.of<Orders>(context, listen: false)
                                  .fetchAndSetOrders(true);
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Your Orders'),
                              actions: const <Widget>[
                                CartIconButton(),
                              ],
                            ),
                            body: FutureBuilder(
                                future: _ordersLoadFuture,
                                builder: (ctx, snapshot) {
                                  return (snapshot.hasError &&
                                          snapshot.connectionState !=
                                              ConnectionState.waiting)
                                      ? _errorAlert(snapshot.error)
                                      : snapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? const ShimmerLoadingList()
                                          : _PageBody(
                                              orderData: orderData,
                                              resetFuture: _resetFuture,
                                            );
                                }),
                          );
                        },
                      ),
                    )
                  : const NotLoggedInScreen('Orders');
            }
          },
        );
      },
    );
  }
}

class _PageBody extends StatefulWidget {
  final VoidCallback resetFuture;
  final Orders orderData;
  const _PageBody({@required this.resetFuture, @required this.orderData});

  @override
  __PageBodyState createState() => __PageBodyState();
}

class __PageBodyState extends State<_PageBody> {
  ScrollController _scrollController;

  bool isLoading = false;

  int limit = 0;

  List<OrderItem> dummytransactionist = [];

  @override
  void initState() {
    paginationFunction();
    super.initState();
  }

  paginationFunction() async {
    limit = min(5, widget.orderData.orders.length);
    setState(() {
      isLoading = false;
    });
    if (limit < widget.orderData.orders.length) {
      for (var i = 0; i < limit; i++) {
        dummytransactionist.add(widget.orderData.orders[i]);
      }
    }
    scrollController();
  }

  void scrollController() {
    _scrollController = ScrollController();
    try {
      _scrollController.addListener(
        () {
          if (_scrollController.offset >=
                  _scrollController.position.maxScrollExtent &&
              !_scrollController.position.outOfRange) {
            setState(() {
              isLoading = true;
            });
            Future.delayed(const Duration(seconds: 1)).then(
              (value) => setState(
                () {
                  if (limit + 10 <= widget.orderData.orders.length) {
                    limit += 10;
                  } else {
                    limit = widget.orderData.orders.length;
                  }
                  isLoading = false;
                  if (limit < widget.orderData.orders.length) {
                    dummytransactionist = [];
                    for (var i = 0; i < limit; i++) {
                      dummytransactionist.add(widget.orderData.orders[i]);
                    }
                  }
                },
              ),
            );
          }
        },
      );
    } catch (e) {
      lg.log(e.toString());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.orderData.setOrders(widget.orderData.orders);
    return RefreshIndicator(
      onRefresh: () => widget.orderData
          .fetchAndSetOrders(true)
          .catchError((_) => widget.resetFuture()),
      child: widget.orderData.orders.isEmpty
          ? Center(
              child: Text(
                'No Orders',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                  width: double.infinity,
                  color: Colors.grey,
                  child: Text(
                    widget.orderData.orders.length <= 1
                        ? '${widget.orderData.orders.length} Order'
                        : '${widget.orderData.orders.length} Orders',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index == limit - 1 &&
                          index != widget.orderData.orders.length - 1) {
                        return Column(
                          children: [
                            OrderListItem(widget.orderData.orders[index]),
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        );
                      }
                      return OrderListItem(widget.orderData.orders[index]);
                    },
                    itemCount: limit,
                  ),
                )
              ],
            ),
    );
  }
}
