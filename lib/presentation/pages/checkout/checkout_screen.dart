import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as lg;
import 'package:confetti/confetti.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washry/domain/promocode_model.dart';
import 'package:washry/domain/service_model.dart';
import '../../../core/network/url.dart';
import 'package:washry/application/auth.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/delivery.dart';
import 'package:washry/application/orders.dart';
import 'package:washry/application/promos.dart';
import 'package:washry/application/serviceIds.dart';
import 'package:washry/application/services.dart';
import '../../../presentation/pages/auth/login_screen.dart';
import '../../../presentation/pages/address/select_address_screen.dart';
import '../../../presentation/components/bottom_fixed_button.dart';
import '../../../presentation/pages/cart/empty_cart_screen.dart';
import '../../components/cart/cart_parent.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  static const String routeName = "checkout-screen";

  const CheckoutScreen({Key key}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  List<String> parentIds = [];
  Map<String, List<String>> map = {};
  bool scrollBarVisibility = true;
  ScrollController controller = ScrollController();
  PromoCodeModel promoCode;
  num subTotal = 0;
  AnimationController _controller;
  // Animation<Offset> _animation;
  // bool _isSelected;
  // List<String> _choices;
  // int _choiceIndex;
  ConfettiController _confettiController;
  Map<String, Map<String, int>> fetchServiceMap = {};
  num get discount {
    return promoCode == null
        ? 0
        : min(subTotal * promoCode.discountPercentage / 100,
            promoCode.maxLiability);
  }

  bool isLoading = false;

  clubServiceId(List<String> serviceIds) {
    map = {};
    var servicesProvier = Provider.of<ServiceProvider>(context, listen: false);
    var svcIds = Provider.of<ServiceIds>(context, listen: false);
    var cartData = Provider.of<CartProvider>(context, listen: false);
    final delivery = Provider.of<SlotProvider>(context, listen: false);
    for (int i = 0; i < serviceIds.length; i++) {
      ServiceModel par = servicesProvier.getParentInfo(serviceIds[i]);
      if (par is MultiServiceModel) {
        if (map.containsKey(par.parentId)) {
          map[par.parentId].add(serviceIds[i]);
        } else {
          map[par.parentId] = [];
          map[par.parentId].add(serviceIds[i]);
        }
      } else if (par is SingleServiceModel) {
        if (map.containsKey(serviceIds[i])) {
          map[serviceIds[i]].add(serviceIds[i]);
        } else {
          map[serviceIds[i]] = [];
          map[serviceIds[i]].add(serviceIds[i]);
        }
      }
    }
    parentIds = map.keys.toList();
    svcIds.updateParentMap(map);
    cartData.updateParentServiceIdsMap(map);
    cartData.expandItemsMap();

    for (var parentId in parentIds) {
      var mapofamount = cartData.getparentIdAmountMap();
      int deliveryCharge =
          delivery.getDeliveryCharge(mapofamount[parentId], parentId);
      cartData.updateDeliveryChargeMap(parentId, deliveryCharge);
    }
    for (var parentId in parentIds) {
      cartData.parentIdNameMap[parentId] =
          servicesProvier.getParentName(parentId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Widget _getAmountDisplayCard(CartProvider cartData) {
    List<String> services = cartData.items.keys.toList();
    var mediaQuery = MediaQuery.of(context);
    double height;
    if (mediaQuery.orientation == Orientation.portrait) {
      height = max(mediaQuery.size.height * .50, 250);
    } else {
      height = max(mediaQuery.size.height * .5, 150);
    }
    return Card(
      elevation: 5.0,
      child: Container(
        padding: const EdgeInsets.all(2),
        height: height,
        child: DraggableScrollbar.arrows(
          controller: controller,
          backgroundColor: Colors.blue,
          alwaysVisibleScrollThumb: scrollBarVisibility,
          child: ListView(
            controller: controller,
            children: parentIds.map((e) {
              return map[e].isNotEmpty
                  ? CartParentComponent(map[e], services, e, fetchServiceMap)
                  : Container();
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _getClearAndAddMoreRow(CartProvider cartData) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Chip(
              elevation: 3,
              backgroundColor: Colors.blue,
              label: Text(
                'Add more',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          TextButton(
            onPressed: () => cartData.clearCart(),
            child: const Chip(
              elevation: 3,
              backgroundColor: Colors.redAccent,
              label: Text(
                'Clear cart',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartProvider>(context, listen: false);
    var deliveryData = Provider.of<SlotProvider>(context, listen: false);
    var authData = Provider.of<AuthProvider>(context, listen: false);
    var svcIds = Provider.of<ServiceIds>(context, listen: false);
    var theme = Theme.of(context);
    List<String> serviceIds = cartData.items.keys.toList();
    svcIds.updateServiceIds(serviceIds);

    //If cart has items
    if (cartData.items.isNotEmpty) {
      validatePromoCode();
      int t = subTotal;
      subTotal = cartData.totalAmount;
      if (t != subTotal) {
        setState(() {});
      }
    }
    return cartData.items.isEmpty
        ? const EmptyCartScreen()
        : isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Review Your Order'),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _getAmountDisplayCard(cartData),
                        _getClearAndAddMoreRow(cartData),
                        _getAmountsDisplayWidget(deliveryData, theme),
                      ],
                    ),
                  ),
                  bottomNavigationBar: BottomFixedButton(
                    text: 'Select Address',
                    onPressed: () => _confirmOrderCallback(
                      cartData,
                      authData,
                      deliveryData,
                    ),
                  ),
                ),
              );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    // _isSelected = false;
    // _choiceIndex = -1;
    // _choices = ["₹30", "₹50", "₹100"];
    // Provider.of<ServiceChargeProvider>(context, listen: false)
    //     .getServiceCharge();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    // _animation = Tween<Offset>(
    //   begin: const Offset(-20, 0),
    //   end: Offset(25, 0),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.easeInCubic,
    //   ),
    // );
    _fetchServiceCharge();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));

    Provider.of<Orders>(context, listen: false)
        .addPromoCodeToCurrentOrder(null);
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        scrollBarVisibility = false;
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  _fetchServiceCharge() async {
    const url =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    responseData.forEach((key, value) {
      fetchServiceMap[key] = {};
      value["delivery"]["price"].forEach((k, v) {
        fetchServiceMap[key][k] = v;
      });
    });
  }

  int flag = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var cartData = Provider.of<CartProvider>(context);
    List<String> serviceIds = cartData.items.keys.toList();
    clubServiceId(serviceIds);
  }

  Future<void> _confirmOrderCallback(CartProvider cartData,
      AuthProvider authData, SlotProvider deliveryData) async {
    try {
      if (_validateMinAmounts(cartData)) {
        //If Logged In
        if (await authData.isAuth()) {
          final orderData = Provider.of<Orders>(context, listen: false);
          final cartData = Provider.of<CartProvider>(context, listen: false);
          orderData.addPromoCodeToCurrentOrder(promoCode.id);
          orderData.getParentIdNameMap(cartData.parentIdNameMap);

          orderData.addAmountToCurrentOrder(
            cartData.getOrderAmountParentMap(discount.floor()),
          );

          orderData.addProductsToCurrentOrder(cartData.cartItemsWithParentId);

          Navigator.of(context).pushNamed(SelectAddressScreen.routeName);
        } //IF not logged in
        else {
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        }
      } // If(minimum order not met
      else {
        _showMinimumOrderAlert();
      }
    } catch (e) {
      lg.log(e.toString());
    }
  }

  void _showMinimumOrderAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Invalid order amount'),
        content: const Text(
            'Check cart summary for minimum order amount of each service.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // void _showDeliveryPrices() {
  //   var deliveryData = Provider.of<Delivery>(context, listen: false);
  //   var chargeList = deliveryData.deliveryCharges.keys.toList();
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       elevation: 0,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //       title: Text(
  //         'Service Charges',
  //         textAlign: TextAlign.center,
  //       ),
  //       content: Container(
  //         height: 170,
  //         width: 240,
  //         child: ListView.builder(
  //           itemCount: chargeList.length,
  //           itemBuilder: (ctx, index) => ListTile(
  //             title: index < chargeList.length - 1
  //                 ? Text('SubTotal upto ${chargeList[index + 1] - 1}')
  //                 : Text('SubTotal above ${chargeList[index] - 1}'),
  //             trailing:
  //                 Text('Rs ${deliveryData.deliveryCharges[chargeList[index]]}'),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  bool _validateMinAmounts(CartProvider cartData) {
    var serviceData = Provider.of<ServiceProvider>(context, listen: false);
    bool serviceAmounts = cartData.items.keys.every((serviceId) =>
        cartData.getAmount(serviceId) >= serviceData.getMinAmount(serviceId));

    bool parentAmounts = cartData.parentServiceIdsMap.keys.every((parentId) =>
        cartData.parentSubtotalAmountMap[parentId] >=
        serviceData.getParentMinAmount(parentId));

    if (serviceAmounts && parentAmounts) {
      return true;
    }
    return false;
  }

  Widget _getAmountsDisplayWidget(SlotProvider deliveryData, ThemeData theme) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    int deliveryCharge = 0;
    cartData.deliveryChargesMap.forEach((key, value) {
      bool isPresent = false;
      for (var element in parentIds) {
        if (element == key) {
          isPresent = true;
        }
      }
      if (isPresent) {
        lg.log('hi');
        lg.log(value.toString());
        deliveryCharge += value;
        lg.log('hello');
      }
    });

    return Card(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Text(
                "Payment Summary",
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Sub-Total ',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    'Rs $subTotal/-',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            if (promoCode != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Discount',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      'Rs ${discount.floor()}/-',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _modalBottomSheetMenu4();
                    },
                    child: Text(
                      'Service Charges',
                      style: theme.textTheme.titleMedium
                          .copyWith(decoration: TextDecoration.underline
                              // deliveryCharge == 0
                              //     ? TextDecoration.lineThrough
                              //     : null,
                              ),
                    ),
                  ),
                  // IconButton(
                  //   alignment: Alignment.topLeft,
                  //   color: theme.primaryColor,
                  //   icon: Icon(
                  //     Icons.info,
                  //     size: 15,
                  //   ),
                  //   onPressed: () => _showDeliveryPrices(),
                  // ),
                  const Spacer(),
                  Text(
                    'Rs $deliveryCharge/-',
                    style: theme.textTheme.titleMedium.copyWith(
                      decoration: deliveryCharge == 0
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total Amount',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    'Rs ${subTotal + deliveryCharge}/-',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  void _modalBottomSheetMenu4() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;
          return SizedBox(
            height: 285,
            child: Column(
              children: [
                // SizedBox(
                //   height: 105,
                // ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, bottom: 25, top: 25),
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.fill,
                      width: width * .16,
                      height: height * .08,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "What is Convenience & Safety Fee?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: height * .009,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 50),
                        child: Text(
                          "This fee goes towards training of partners and providing support,safety equipment and assistance during the service.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * .026,
                ),
                const Divider(),
                SizedBox(
                    width: width * .9,
                    height: height * .055,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text("Okay,got it"),
                    ))
              ],
            ),
          );
        });
  }

  // void _promoCodeButtonCallback() async {
  //   if (await Provider.of<Auth>(context, listen: false).isAuth())
  //     Navigator.of(context).pushNamed(PromoCodeScreen.routeName).then((value) {
  //       setState(() {});
  //     });
  //   else
  //     Navigator.of(context).pushNamed(LoginScreen.routeName);
  // }

  void validatePromoCode() {
    final orderData = Provider.of<Orders>(context, listen: false);
    var promoCodeId = orderData.getCurrentOrderPromoCode();
    promoCode =
        Provider.of<Promos>(context, listen: false).getPromo(promoCodeId);

    if (promoCode == null) return;
    final cartData = Provider.of<CartProvider>(context, listen: false);
    if (!_validateCartAmount(cartData)) {
      promoCode = null;
      return;
    }
    if (promoCode.endDate.isBefore(DateTime.now())) {
      promoCode = null;
      return;
    }
  }

  bool _validateCartAmount(CartProvider cartData) =>
      promoCode.minCartAmount.keys.every((serviceID) =>
          cartData.getAmount(serviceID) >= promoCode.minCartAmount[serviceID]);

  // Widget _getTipDisplaySection() {
  //   // we have to put this tip display where we give payment
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: Container(
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5),
  //           border: Border.all(color: Theme.of(context).primaryColor)),
  //       child: Column(
  //         children: [
  //           ListTile(
  //             minLeadingWidth: 15,
  //             leading: Icon(
  //               Icons.volunteer_activism,
  //               color: Theme.of(context).primaryColor,
  //             ),
  //             title: Text("Thank you for adding a Tip!"),
  //             isThreeLine: true,
  //             subtitle: Text(
  //                 "Thank you for your generous tips for your future orders. They'll be passed on to your service partner as soon as the orders are completed."),
  //           ),
  //           Row(
  //             children: [
  //               Spacer(),
  //               Container(
  //                 width: MediaQuery.of(context).size.width - 80,
  //                 height: 40,
  //                 child: ListView.builder(
  //                   shrinkWrap: true,
  //                   scrollDirection: Axis.horizontal,
  //                   itemCount: _choices.length,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     return Padding(
  //                       padding: const EdgeInsets.only(left: 5, right: 5),
  //                       child: ChoiceChip(
  //                         shape: StadiumBorder(
  //                           side: BorderSide(
  //                             color: Theme.of(context).primaryColor,
  //                           ),
  //                         ),
  //                         elevation: 2,
  //                         padding: const EdgeInsets.all(10),
  //                         label: Text(_choices[index]),
  //                         selected: _choiceIndex == index,
  //                         selectedColor: Theme.of(context).primaryColor,
  //                         onSelected: (bool selected) {
  //                           if (_controller.isDismissed) {
  //                             setState(() {
  //                               _choiceIndex = selected ? index : -1;
  //                               _isSelected = !selected;
  //                               if (_controller.isDismissed &&
  //                                   _isSelected == false) {
  //                                 _controller.forward();
  //                                 _confettiController.play();
  //                                 Timer(
  //                                   Duration(milliseconds: 1800),
  //                                   () {
  //                                     _controller.reset();
  //                                     _confettiController.stop();
  //                                   },
  //                                 );
  //                                 return;
  //                               }
  //                             });
  //                           }
  //                         },
  //                         backgroundColor: Colors.white,
  //                         labelStyle: _choiceIndex == index
  //                             ? TextStyle(color: Colors.white)
  //                             : TextStyle(color: Colors.black),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 15,
  //               )
  //             ],
  //           ),
  //           _controller.isAnimating
  //               ? ConfettiWidget(
  //                   confettiController: _confettiController,
  //                   blastDirectionality: BlastDirectionality.directional,
  //                   blastDirection: 5,
  //                   colors: const [
  //                     Colors.green,
  //                     Colors.blue,
  //                     Colors.pink,
  //                     Colors.orange,
  //                     Colors.purple
  //                   ],
  //                   child: SlideTransition(
  //                     position: _animation,
  //                     child: Container(
  //                       width: 10,
  //                       height: 50,
  //                       color: Colors.green,
  //                     ),
  //                   ),
  //                 )
  //               : Container(),
  //           _controller.isCompleted || _controller.isDismissed
  //               ? SizedBox(
  //                   height: 10,
  //                 )
  //               : Container(),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
