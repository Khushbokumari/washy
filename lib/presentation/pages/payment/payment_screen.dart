import 'dart:async';
import 'dart:convert';
import 'dart:developer' as lg;
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:washry/domain/order_item.dart';
import 'package:washry/domain/promocode_model.dart';
import 'package:washry/domain/transaction.dart';
import 'package:washry/domain/transaction_history.dart';
import '../../../core/network/url.dart';
import 'package:washry/application/auth.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/delivery.dart';
import 'package:washry/application/locations.dart';
import 'package:washry/application/orders.dart';
import 'package:washry/application/promos.dart';
import 'package:washry/application/serviceIds.dart';
import 'package:washry/application/services.dart';
import '../../../presentation/pages/auth/login_screen.dart';
import '../../../presentation/pages/checkout/promocode_screen.dart';
import '../../../presentation/pages/dashboard/order/order_placed_screen.dart';
import '../../../presentation/components/bottom_fixed_button.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  static const String routeName = 'Payment-Screen';

  const PaymentScreen({Key? key}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  // Promo code
  late PromoCodeModel promoCode;
  num subTotal = 0;
  num subTotalForPromo = 0;
  late String userId;
  var result;
  double amounts = 0;
  double prevWallet = 0;
  late OrderItem item;
  //TIP
  var responseData;
  double coinsPercentage = 0;
  double maxCoinsUsage = 0;
  var responseDataOfAvailableSlot;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late List<String> _choices;
  int _choiceIndex = -1;
  late bool _isSelected;
  late ConfettiController _confettiController;
  bool scrollBarVisibility = true;
  var responseDataOfUserInfo;
  int applyCoin = 0;
  var response;
  bool isSufficientAmount = false;
  bool isEnable = true;
  List<String> paymentOptions = [
    'Cash Payment',
    'UPI Payment',
    'Washry Wallet',
  ];
  int indexOfPaymentOption = 0;
  int selected = 0;
  bool loading = false;
  bool isWalletMoneyLoading = false;
  int walletCoins = 0;
  int firebaseWalletCoins = 0;
  late Map<String, bool> servicesNature;
  int slotsFlag = 1;

  num get discount {
    return (promoCode == null && isEnable)
        ? 0
        : min(
            amounts,
            (promoCode != null
                ? min(subTotalForPromo * promoCode.discountPercentage / 100,
                    promoCode.maxLiability)
                : 0 +
                    (!isEnable
                        ? min(maxCoinsUsage,
                                min(subTotal * coinsPercentage, walletCoins))
                            .round()
                        : 0)));
  }

  isApplicableForWashryMoney() async {
    setState(() {
      isWalletMoneyLoading = true;
    });
    userId = FirebaseAuth.instance.currentUser!.uid;
    final transUrl = "${URL.TRANSACTION_URL}/$userId.json";
    result = await http.get(Uri.parse(transUrl));

    try {
      responseData = jsonDecode(result.body) as Map<String, dynamic>;
      if (responseData != null) {
        prevWallet = responseData["walletMoney"].toDouble() ?? 0.0;
      }
    } catch (e) {
      rethrow;
    }
    setState(() {
      isWalletMoneyLoading = false;
    });
  }

  Widget _getPromoDisplaySection(ThemeData theme) {
    return Card(
      child: ListTile(
          title: Text(
            promoCode.name ?? "COUPON CODE".toUpperCase(),
            textAlign: TextAlign.start,
          ),
          subtitle: promoCode == null ? null : Text(promoCode.name),
          trailing: promoCode == null
              ? ElevatedButton(
                  onPressed:
                      promoCode != null ? null : _promoCodeButtonCallback,
                  child: const Text("List"))
              : _removePromoButton),
    );
  }

  Widget get _removePromoButton => IconButton(
        icon: const Icon(
          Icons.remove_circle,
          size: 30,
        ),
        onPressed: () {
          setState(() {
            Provider.of<Orders>(context, listen: false)
                .addPromoCodeToCurrentOrder('');
          });
        },
      );

  void _promoCodeButtonCallback() async {
    if (await Provider.of<AuthProvider>(context, listen: false).isAuth()) {
      Navigator.of(context).pushNamed(PromoCodeScreen.routeName).then((value) {
        setState(() {});
      });
    } else {
      Navigator.of(context).pushNamed(LoginScreen.routeName);
    }
  }

  void validatePromoCode() {
    final orderData = Provider.of<Orders>(context, listen: false);
    var promoCodeId = orderData.getCurrentOrderPromoCode();
    promoCode =
        Provider.of<Promos>(context, listen: false).getPromoMap(promoCodeId);
    if (promoCode == null) return;
    final cartData = Provider.of<CartProvider>(context, listen: false);
    if (!_validateCartAmount(cartData)) {
      promoCode == null;
      return;
    }
    if (promoCode.endDate.isBefore(DateTime.now())) {
      promoCode == null;
      return;
    }
  }

  bool _validateCartAmount(CartProvider cartData) {
    if (promoCode.type == "parent") {
      final svcIds = Provider.of<ServiceIds>(context, listen: false);
      var total = 0;
      for (var serviceId
          in svcIds.map[promoCode.minCartAmount.keys.toList()[0]]!) {
        // total += cartData.getAmount(serviceId);
        total += cartData.getAmount(serviceId)!.toInt();

      }
      return promoCode.minCartAmount.keys
          .every((serviceID) => total >= promoCode.minCartAmount[serviceID]!);
    } else if (promoCode.type == "service") {
      return promoCode.minCartAmount.keys.every((serviceID) =>
          cartData.getAmount(serviceID)! >= promoCode.minCartAmount[serviceID]!);
    } else {
      final servicesProvier =
          Provider.of<ServiceProvider>(context, listen: false);

      var temp = servicesProvier
          .getserviceInfoforproduct(promoCode.minCartAmount.keys.toList()[0]);
      bool isValid = promoCode.minCartAmount.keys.every((productId) {
        return cartData.getProductAmount(temp.serviceId, productId)! >=
            promoCode.minCartAmount[productId]!;
      });
      return isValid;
    }
  }

  Widget _getTipDisplaySection() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).primaryColor)),
        child: Column(
          children: [
            ListTile(
              minLeadingWidth: 15,
              leading: Icon(
                Icons.volunteer_activism,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text("Thank you for adding a Tip!"),
              isThreeLine: true,
              subtitle: const Text(
                  "Thank you for your generous tips for your future orders. They'll be passed on to your service partner as soon as the orders are completed."),
            ),
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _choices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ChoiceChip(
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.all(10),
                          label: Text(_choices[index]),
                          selected: _choiceIndex == index,
                          selectedColor: Theme.of(context).primaryColor,
                          onSelected: (bool isSelected) {
                            if (_controller.isDismissed) {
                              setState(() {
                                _choiceIndex = isSelected ? index : -1;
                                if (_choiceIndex != -1) {
                                  amounts += int.parse(
                                      _choices[_choiceIndex].substring(1));
                                  if (selected == 2) {
                                    if (amounts > prevWallet) {
                                      setState(() {
                                        selected = 0;
                                      });
                                    }
                                  }
                                }
                                _isSelected = !isSelected;
                                if (_controller.isDismissed &&
                                    _isSelected == false) {
                                  _controller.forward();
                                  _confettiController.play();
                                  Timer(
                                    const Duration(milliseconds: 1800),
                                    () {
                                      _controller.reset();
                                      _confettiController.stop();
                                    },
                                  );
                                  return;
                                }
                              });
                            }
                          },
                          backgroundColor: Colors.white,
                          labelStyle: _choiceIndex == index
                              ? const TextStyle(color: Colors.white)
                              : const TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 15,
                )
              ],
            ),
            _controller.isAnimating
                ? ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.directional,
                    blastDirection: 5,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ],
                    child: SlideTransition(
                      position: _animation,
                      child: Container(
                        width: 10,
                        height: 50,
                        color: Colors.green,
                      ),
                    ),
                  )
                : Container(),
            _controller.isCompleted || _controller.isDismissed
                ? const SizedBox(
                    height: 10,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _getAmountsDisplayWidget(
    SlotProvider deliveryData,
    ThemeData theme,
  ) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final svcIds = Provider.of<ServiceIds>(context);
    double deliveryCharge = 0;
    cartData.deliveryChargesMap.forEach((key, value) {
      bool isPresent = false;
      for (var element in svcIds.parentId) {
        if (element == key) {
          isPresent = true;
        }
      }
      if (isPresent) {
        deliveryCharge += value;
      }
    });
    amounts = subTotal + deliveryCharge - discount;

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
            const SizedBox(
              height: 5,
            ),
            (promoCode != null || discount != 0)
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Discount',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Text(
                          'Rs ${discount.floor()}/-',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  )
                : Container(),
            _choiceIndex != -1
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text('Tip', style: theme.textTheme.titleLarge),
                        const Spacer(),
                        Text("Rs " + _choices[_choiceIndex].substring(1) + '/-',
                            style: theme.textTheme.titleLarge),
                      ],
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                children: <Widget>[
                  Text('Total Amount', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text(
                      "Rs" +
                          (subTotal +
                                  deliveryCharge -
                                  discount +
                                  (_choiceIndex != -1
                                      ? int.parse(
                                          _choices[_choiceIndex].substring(1))
                                      : 0))
                              .toString() +
                          '/-',
                      style: theme.textTheme.titleLarge),
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

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    isApplicableForWashryMoney();
    getWalletCoin();
    selected = 0;
    loading = false;
    final orderData = Provider.of<Orders>(context, listen: false);
    orderData.addPaymentModeToCurrentOrder(paymentOptions[selected]);
    servicesNature =
        Provider.of<ServiceProvider>(context, listen: false).getServiceNature();

    _isSelected = false;
    _choiceIndex = -1;
    _choices = ["₹30", "₹50", "₹100"];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(-20, 0),
      end: const Offset(25, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInCubic,
      ),
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));

    Provider.of<Orders>(context, listen: false)
        .addPromoCodeToCurrentOrder('');
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        scrollBarVisibility = false;
      });
    });
  }

  getWalletCoin() async {
    final userIdd = FirebaseAuth.instance.currentUser?.uid;
    var url = "${URL.USER_INFO_URL}/$userIdd.json";
    response = await http.get(Uri.parse(url));
    responseDataOfUserInfo = jsonDecode(response.body) as Map<String, dynamic>;
    try {
      walletCoins = responseDataOfUserInfo["wallet"] ?? 0;
    } catch (e) {
      e.toString();
    }
    firebaseWalletCoins = walletCoins;
    const offerurl = "${URL.OFFERS_URL}/coins.json";
    final res = await http.get(Uri.parse(offerurl));
    final responseData = jsonDecode(res.body) as Map<String, dynamic>;
    coinsPercentage = responseData["coinsPercentage"] / 100.0;
    maxCoinsUsage = responseData["maxCoinsUsage"] / 1.0;
  }

  @override
  Widget build(BuildContext context) {
    var cartData = Provider.of<CartProvider>(context);
    final orderData = Provider.of<Orders>(context, listen: false);
    var deliveryData = Provider.of<SlotProvider>(context, listen: false);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (cartData.items.isNotEmpty) {
      validatePromoCode();
      subTotal = cartData.totalAmount;
      if (promoCode.type == "parent") {
        String parentId = promoCode.minCartAmount.keys.toList()[0];
        final svcIds = Provider.of<ServiceIds>(context, listen: false);
        List<String>? listOfServiceIds = svcIds.map[parentId];
        subTotalForPromo = cartData.totalAmountParent(listOfServiceIds!) as num;
      } else if (promoCode.type == "service") {
        subTotalForPromo = cartData.totalAmount;
      } else {
        final servicesProvier =
            Provider.of<ServiceProvider>(context, listen: false);
        var temp = servicesProvier.getserviceInfoforproduct(
            promoCode.minCartAmount.keys.toList()[0]);
        subTotalForPromo = cartData.getProductAmount(
            temp.serviceId, promoCode.minCartAmount.keys.toList()[0]) as num;
      }
    }
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Payment',
            ),
          ),
          body: (loading || response == null || isWalletMoneyLoading)
              ? const Center(child: Text('hello'))
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Card(
                        elevation: 5,
                        child: SizedBox(
                          height: 170,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'Choose Payment Option',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: SizedBox(
                                      height: 78,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: paymentOptions.length,
                                        itemBuilder: (ctx, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (index == 2) {
                                                indexOfPaymentOption = index;
                                                if (result == null) {
                                                  Fluttertoast.showToast(
                                                    msg: "Not Available",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                  );
                                                  return;
                                                }
                                                final cartData =
                                                    Provider.of<CartProvider>(
                                                        context,
                                                        listen: false);
                                                final svcIds =
                                                    Provider.of<ServiceIds>(
                                                        context,
                                                        listen: false);
                                                double deliveryCharge = 0;

                                                cartData.deliveryChargesMap
                                                    .forEach((key, value) {
                                                  bool isPresent = false;
                                                  for (var element
                                                      in svcIds.parentId) {
                                                    if (element == key) {
                                                      isPresent = true;
                                                    }
                                                  }
                                                  if (isPresent) {
                                                    deliveryCharge += value;
                                                  }
                                                });
                                                amounts = subTotal +
                                                    deliveryCharge -
                                                    discount;
                                                if (_choiceIndex != -1) {
                                                  amounts += int.parse(
                                                      _choices[_choiceIndex]
                                                          .substring(1));
                                                } else {}
                                                if (result != null) {
                                                  final responseData =
                                                      jsonDecode(result.body)
                                                          as Map<String,
                                                              dynamic>;
                                                  if (amounts > prevWallet) {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'Insufficient Wallet Money',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                    );
                                                    return;
                                                  }
                                                }
                                                if (amounts > prevWallet) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Insufficient Wallet Money',
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                  );
                                                  return;
                                                }
                                              }
                                              setState(() {
                                                selected = index;
                                                indexOfPaymentOption = index;
                                                orderData
                                                    .addPaymentModeToCurrentOrder(
                                                        paymentOptions[
                                                            selected]);
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                alignment: Alignment.center,
                                                height: 120,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: index == selected
                                                      ? theme.primaryColor
                                                      : theme.primaryColor
                                                          .withOpacity(.1),
                                                ),
                                                child: Text(
                                                  paymentOptions[index],
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                          color: index ==
                                                                  selected
                                                              ? Colors.white
                                                              : Colors.grey),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )))
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          DefaultTabController(
                            length: 2, // length of tabs
                            initialIndex: 0,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  TabBar(
                                    isScrollable: true,
                                    labelColor: theme.primaryColor,
                                    unselectedLabelColor: Colors.black,
                                    tabs: const [
                                      Tab(text: 'Promo Code'),
                                      Tab(text: 'Points'),
                                    ],
                                  ),
                                  Container(
                                      height: 70, //height of TabBarView
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.5))),
                                      child: TabBarView(children: <Widget>[
                                        Container(
                                          child: _getPromoDisplaySection(theme),
                                        ),
                                        Container(
                                          child: walletCoins != 0
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: width * .47,
                                                        height: height * 0.06,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "You can use ${min(maxCoinsUsage, min(subTotal * coinsPercentage, walletCoins)).round()} points for discount worth ${min(maxCoinsUsage, min(subTotal * coinsPercentage, walletCoins)).round()}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 100,
                                                      ),
                                                      ElevatedButton(
                                                          child:
                                                              const Text("USE"),
                                                          onPressed: () {
                                                            setState(() {});
                                                            isEnable =
                                                                !isEnable;
                                                            isEnable
                                                                ? walletCoins =
                                                                    walletCoins
                                                                : walletCoins = min(
                                                                        maxCoinsUsage,
                                                                        min(
                                                                            subTotal *
                                                                                coinsPercentage,
                                                                            walletCoins))
                                                                    .round();
                                                            setState(() {});
                                                          })
                                                    ],
                                                  ),
                                                )
                                              : responseDataOfUserInfo == null
                                                  ? const Center(
                                                      child: Text('hi'),
                                                    )
                                                  : Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                          "Not sufficient points")),
                                        ),
                                      ]))
                                ]),
                          ),
                        ],
                      ),
                      _getTipDisplaySection(),
                      _getAmountsDisplayWidget(deliveryData, theme),
                      const SizedBox(
                        height: 8,
                      ),
                      const Row(
                        children: [
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Message',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                orderData
                                    .addInstructionToCurrentOrder(value.trim());
                              }
                            },
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: "Instructions (Optional)",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar:
              !(loading || response == null || isWalletMoneyLoading)
                  ? BottomFixedButton(
                      text: 'Place Order',
                      onPressed: _placeOrderCallback,
                    )
                  : const Center(child: CircularProgressIndicator())),
    );
  }

  updateSlots() async {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = Provider.of<ServiceProvider>(context, listen: false);
    svcIds.availableSlotsMap.forEach((parentId, pickupSlotsInfo) async {
      final url =
          "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parentId/delivery.json";
      final response = await http.get(Uri.parse(url));
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      var pickupSlots = responseData['slots'];
      var deliverySlots = (responseData['del']);

      // String pickupKey;
      pickupSlots.forEach((key, value) async {
        if (pickupSlotsInfo.from == value['from'] &&
            pickupSlotsInfo.to == value['to']) {
          lg.log("value..   ${value['availableSlots']}");
          if (value['availableSlots'] > 0) {
            int availableSlots = value['availableSlots'];
            --availableSlots;

            svcIds.availabledelSlotsMap.forEach((parentId2, delslotsInfo) {
              if (!servicesNature[parentId2]!) {
                deliverySlots.forEach((delKey, delValue) async {
                  if (delslotsInfo.from == delValue['from'] &&
                      delslotsInfo.to == delValue['to']) {
                    lg.log("del ... ${delValue['availableSlots']}");
                    if (delValue['availableSlots'] > 0) {
                       int availableDelSlots = delValue['availableSlots'];
                      --availableDelSlots;
                      var delPatchUrl =
                          "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parentId/delivery/del/$key.json?auth=${auth.token}";
                      await http.patch(Uri.parse(delPatchUrl),
                          body: jsonEncode(
                              {'availableSlots': availableDelSlots}));
                    } else {
                      slotsFlag = 0;
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Unavailable Slots"),
                              content: Text(
                                  'The Delivery Slot you selected for ${service.getParentName(parentId2)} are completely booked. Try choosing another slot.'),
                              actions: [
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PaymentScreen()));
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  }
                });
              }
            });
            var patchUrl =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parentId/delivery/slots/$key.json?auth=${auth.token}";
            await http.patch(Uri.parse(patchUrl),
                body: jsonEncode({
                  "availableSlots": availableSlots,
                }));
          } else {
            slotsFlag = 0;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Unavailable Slots"),
                    content: Text(
                        'The Pickup Slot you selected for ${service.getParentName(parentId)} are completely booked. Try choosing another slot.'),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PaymentScreen()));
                        },
                      ),
                    ],
                  );
                });
          }
        }
      });
    });
  }

  Future<void> placeOrder() async {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    const url =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    svcIds.availableSlotsMap.forEach((element, value) async {
      responseData.forEach((key, val) async {
        if (key == element) {
          if (value.availableSlots > 0) {
            value.availableSlots--; //8
            svcIds.updateselectedAvailable(element, value);
            final ur =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$key/delivery/slots.json";

            final response = await http.get(Uri.parse(ur));
            final responseData =
                jsonDecode(response.body) as Map<String, dynamic>;

            responseData.forEach((k, v) async {
              if (value.from == v["from"]) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final urll =
                    "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$key/delivery/slots/$k.json?auth=${auth.token}";

                await http.patch(Uri.parse(urll),
                    body: jsonEncode({
                      "availableSlots": value.availableSlots,
                      "from": value.from,
                      "to": value.to
                    }));
              }
            });
          }
        }
      });
    });
  }

  Future<void> availableSlot() async {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    const url =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services.json";
    final response = await http.get(Uri.parse(url));
    responseDataOfAvailableSlot =
        jsonDecode(response.body) as Map<String, dynamic>;

    svcIds.availabledelSlotsMap.forEach((element, value) async {
      responseDataOfAvailableSlot.forEach((key, val) async {
        if (key == element) {
          if (value.availableSlots > 0) {
            final ur =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$key/delivery/del.json";

            await http.get(Uri.parse(ur));
          }
        }
      });
    });
  }

  Future<void> place() async {
    final svcIds = Provider.of<ServiceIds>(context, listen: false);
    const url =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    svcIds.availabledelSlotsMap.forEach((element, value) async {
      responseData.forEach((key, val) async {
        if (key == element) {
          if (value.availableSlots > 0) {
            value.availableSlots--;
            svcIds.updatedeliveryAvailable(element, value);

            final ur =
                "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$key/delivery/del.json";

            final response = await http.get(Uri.parse(ur));
            final responseData =
                jsonDecode(response.body) as Map<String, dynamic>;

            responseData.forEach((k, v) async {
              if (value.from == v["from"]) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final urll =
                    "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$key/delivery/del/$k.json?auth=${auth.token}";
                await http.patch(Uri.parse(urll),
                    body: jsonEncode({
                      "availableSlots": value.availableSlots,
                      "from": value.from,
                      "to": value.to
                    }));
              }
            });
          }
        }
      });
    });
  }

  walletMoney(orderId) async {
    final url = "${URL.TRANSACTION_URL}/$userId.json";
    final urll = "${URL.TRANSACTION_URL}/$userId/transHistory.json";

    MoneyTransaction transaction = MoneyTransaction();
    transaction.walletMoney = prevWallet - amounts;
    TransactionHistory transactionHistory = TransactionHistory();
    transactionHistory.date = DateTime.now();
    transactionHistory.amount = amounts;
    transactionHistory.orderId = orderId;
    transactionHistory.credit = false;
    transactionHistory.debit = true;
    transactionHistory.title = "Order Completed";
    await http.patch(Uri.parse(url), body: jsonEncode(transaction.toJson()));
    await http.post(Uri.parse(urll),
        body: jsonEncode(transactionHistory.toJson()));
  }

  coinsMoney(orderId) async {
    final url = "${URL.TRANSACTION_URL}/$userId/transHistory.json";

    TransactionHistory transactionHistory = TransactionHistory();
    transactionHistory.date = DateTime.now();
    transactionHistory.amount =
        min(maxCoinsUsage, min(subTotal * coinsPercentage, walletCoins * 1.0))
                .round() /
            1.0;
    transactionHistory.orderId = orderId;
    transactionHistory.credit = false;
    transactionHistory.debit = true;
    transactionHistory.title = "Order Completed";

    try {
      transactionHistory.coins = responseDataOfUserInfo["wallet"];

      await http.post(Uri.parse(url),
          body: jsonEncode(transactionHistory.toJson()));
    } catch (e) {
      lg.log(e.toString());
    }
  }

  updateCoins() async {
    final userIdd = FirebaseAuth.instance.currentUser?.uid;
    var url = "${URL.USER_INFO_URL}/$userIdd.json";

    int k = firebaseWalletCoins -
        min(maxCoinsUsage, min(subTotal * coinsPercentage, walletCoins))
            .round();
    await http.patch(Uri.parse(url), body: jsonEncode({"wallet": k}));

    final urll = "${URL.TRANSACTION_URL}/$userId.json";

    await http.patch(Uri.parse(urll),
        body: jsonEncode({"walletCoins": k / 1.0}));
  }

  Future<void> _placeOrderCallback() async {
    setState(() {
      loading = true;
    });

    try {
      final svcIds = Provider.of<ServiceIds>(context, listen: false);
      String locationId = Provider.of<LocationProvider>(context, listen: false)
          .currentOperationLocation
          .locationId;
      var orders = Provider.of<Orders>(context, listen: false);

      orders.addPromoCodeToCurrentOrder(promoCode.name);
      orders.addDiscountAndTipToCurrentOrder(
          discount,
          (_choiceIndex != -1
              ? int.parse(_choices[_choiceIndex].substring(1))
              : 0));
      lg.log("slots flag $slotsFlag");
      updateSlots();
      Future.delayed(const Duration(seconds: 4)).then((value) {
        lg.log("slots flag amit $slotsFlag");
        if (slotsFlag == 1) {
          lg.log("slots flag2 $slotsFlag");
          orders
              .addOrder(
            locationId,
            svcIds.mapOfParentIdsForSlots,
            servicesNature,
          )
              .then((value) async {
            svcIds.resetMap();
            // await place();
            // await placeOrder();
            if (selected == 2) {
              await walletMoney(value);
            }
            if (isEnable == false) {
              await coinsMoney(value);
              await updateCoins();
            }
          });
          Provider.of<CartProvider>(context, listen: false).clearCart();

          Navigator.of(context).popUntil((route) => !route.navigator!.canPop());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  OrderPlacedScreen()));
        } else {
          lg.log("successful :) ");
        }
      });

      // Provider.of<Cart>(context, listen: false).clearCart();

      // Navigator.of(context).popUntil((route) => !route.navigator.canPop());
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => OrderPlacedScreen()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
          content: const Text('Network error'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }
}
