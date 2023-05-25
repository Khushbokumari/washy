import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washry/domain/promocode_model.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/promos.dart';
import 'package:washry/application/serviceIds.dart';
import 'package:washry/application/services.dart';
import '../../components/cart/promo_list_item.dart';

class PromoCodeScreen extends StatefulWidget {
  static const routeName = 'PromoCode-Screen';

  const PromoCodeScreen({Key ?key}) : super(key: key);

  @override
  PromoCodeScreenState createState() => PromoCodeScreenState();
}

class PromoCodeScreenState extends State<PromoCodeScreen> {
  List<PromoCodeModel> available = [], unavailable = [];

  @override
  void initState() {
    super.initState();
    _setAvailableAndUnavailablePromos();
  }

  bool _validateCartAmount(CartProvider cartData, PromoCodeModel item) {
    if (item.type == "parent") {
      try {
        final svcIds = Provider.of<ServiceIds>(context, listen: false);
        var total = 0;
        // log("lololo "+item.minCartAmount.keys.toList()[0].toString());
        if (svcIds.map.containsKey(item.minCartAmount.keys.toList()[0])) {
          for (var serviceId
              in svcIds.map[item.minCartAmount.keys.toList()[0]]) {
            total += cartData.getAmount(serviceId);
          }

          return item.minCartAmount.keys
              .every((serviceID) => total >= item.minCartAmount[serviceID]);
        } else {
          return false;
        }
      } catch (e) {
        log(e.toString());
      }
    } else if (item.type == "service") {
      log("service");
      return item.minCartAmount.keys.every((serviceID) {
        log(cartData.getAmount(serviceID).toString());
        return cartData.getAmount(serviceID) >= item.minCartAmount[serviceID];
      });
    } else {
      final servicesProvier =
          Provider.of<ServiceProvider>(context, listen: false);
      var temp = servicesProvier
          .getserviceInfoforproduct(item.minCartAmount.keys.toList()[0]);
      bool isValid = item.minCartAmount.keys.every((productId) {
        return cartData.getProductAmount(temp.serviceId, productId) >=
            item.minCartAmount[productId];
      });
      return isValid;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose PromoCode'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //Any PromoCode is available
              if (available.isNotEmpty) ..._getAvailablePromoCodeSection(theme),

              //  if (available.length > 0) Text("helloworld"),

              // if (available.length == 0)
              //   Center(
              //     heightFactor: media.size.height * 0.02,
              //     child: Padding(
              //       padding: const EdgeInsets.only(right: 10.0, left: 10.0),
              //       child: Text(
              //         'No promo codes available right now at your location',
              //         style: theme.textTheme.titleSmall.copyWith(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),
              if (available.isEmpty) ..._getUnavailablePromoCodeSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getUnavailablePromoCodeSection(ThemeData theme) => [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Unavailable Codes',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...unavailable.map((item) => PromoListItem(item, false)).toList(),
        const SizedBox(
          height: 10,
        ),
      ];

  List<Widget> _getAvailablePromoCodeSection(ThemeData theme) => [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Available Codes',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...available.map((item) => PromoListItem(item, true)).toList()
      ];

  void _setAvailableAndUnavailablePromos() {
    var promoData = Provider.of<Promos>(context, listen: false);
    final cartData = Provider.of<CartProvider>(context, listen: false);
    promoData.promosMap.forEach((key, value) {
      for (var item in value) {
        log("$item ${_validateCartAmount(cartData, item)}");
        if (_validateCartAmount(cartData, item) &&
            item.endDate.isAfter(DateTime.now())) {
          available.add(item);
        } else {
          unavailable.add(item);
        }
      }
    });
  }
}
