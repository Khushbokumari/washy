import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/cart_model.dart';
import '../../../application/cart.dart';
import '../../../application/services.dart';
import 'cart_product.dart';

class CheckoutServiceItem extends StatefulWidget {
  final String serviceId;

  const CheckoutServiceItem(this.serviceId, {Key key}) : super(key: key);

  @override
  CheckoutServiceItemState createState() => CheckoutServiceItemState();
}

class CheckoutServiceItemState extends State<CheckoutServiceItem> {
  Widget _getHeaderWidget(BuildContext context, num totalAmount) {
    final serviceData = Provider.of<ServiceProvider>(context, listen: false);
    var theme = Theme.of(context);
    var minAmount = serviceData.getMinAmount(widget.serviceId);

    return Row(
      children: <Widget>[
        Text(
          '${serviceData.getServiceName(widget.serviceId)} ',
          style: theme.textTheme.titleLarge.copyWith(
            fontSize: 15,
          ),
        ),
        minAmount >= totalAmount
            ? Text(
                '(Min : Rs.$minAmount) ',
                style: theme.textTheme.titleLarge.copyWith(
                  fontSize: 14,
                ),
              )
            : const SizedBox(),
        const Spacer(),
        Text(
          'Amount',
          style: theme.textTheme.titleLarge.copyWith(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final Map<String, CartModel> cartItems = cartData.items[widget.serviceId];
    final theme = Theme.of(context);
    var totalAmount = cartData.getAmount(widget.serviceId);
    return cartItems != null
        ? Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(.2),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _getHeaderWidget(context, totalAmount),
                ..._getListOfProducts(cartData),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 3, left: 12, bottom: 8, top: 8),
                  child: Row(
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        totalAmount.toString(),
                        style: theme.textTheme.titleLarge.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )

                // _getservicecharge(deliveryData, cartData, theme),
                //_getRightAlignedTotal(deliveryData, cartData, theme),
              ],
            ),
          )
        : Container();
    // ]);
  }

  // void _showDeliveryPrices(BuildContext context) {
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
  //                 ? Text('SubTotal upto ${chargeList[1]}')
  //                 : Text('SubTotal above ${chargeList[index]}'),
  //             trailing:
  //                 Text('Rs ${deliveryData.deliveryCharges[chargeList[index]]}'),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  List<Widget> _getListOfProducts(CartProvider cartData) {
    final Map<String, CartModel> cartItems = cartData.items[widget.serviceId];
    final List<String> productIds =
        cartItems != null ? cartItems.keys.toList() : [];
    return productIds
        .map(
          (productId) => CartProductComponent(
            serviceId: widget.serviceId,
            cartItem: cartItems[productId],
            productId: productId,
          ),
        )
        .toList();
  }

  // Widget _getservicecharge(
  //   Delivery deliveryData, Cart cartData, ThemeData theme) {
  //   final Map<String, CartModel> cartItems = cartData.items[widget.serviceId];
  //   final List<String> productIds =cartItems!=null? cartItems.keys.toList():[];
  //   var _total = productIds
  //       .map((e) => cartItems[e].price * cartItems[e].quantity)
  //       .toList();
  //   int sum = 0;
  //   _total.forEach((val) {
  //     sum += val;
  //   });
  //   final deliveryCharge = deliveryData.getDeliveryCharge(sum);
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 10),
  //     child: Row(
  //       children: <Widget>[
  //         Text(
  //           'Service Charges',
  //           style: theme.textTheme.titleMedium.copyWith(
  //             decoration:
  //                 deliveryCharge == 0 ? TextDecoration.lineThrough : null,
  //           ),
  //         ),
  //         IconButton(
  //           alignment: Alignment.topLeft,
  //           color: theme.primaryColor,
  //           icon: Icon(
  //             Icons.info,
  //             size: 15,
  //           ),
  //           onPressed: () => _showDeliveryPrices(context),
  //         ),
  //         Spacer(),
  //         Text(
  //           deliveryCharge.toString(),
  //           style: theme.textTheme.titleMedium.copyWith(
  //             decoration:
  //                 deliveryCharge == 0 ? TextDecoration.lineThrough : null,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _getRightAlignedTotal(
  //     Delivery deliveryData, Cart cartData, ThemeData theme) {
  //   final Map<String, CartModel> cartItems = cartData.items[widget.serviceId];

  //   final List<String> productIds =
  //       cartItems != null ? cartItems.keys.toList() : [];
  //   // final svcIds = Provider.of<ServiceIds>(context);
  //   // int x = svcIds.parlen;
  //   // String parId = svcIds.parentIds[x];

  //   var _total = productIds
  //       .map((e) => cartItems[e].price * cartItems[e].quantity)
  //       .toList();

  //   int sum = 0;
  //   _total.forEach((val) {
  //     sum += val;
  //   });
  //   num deliveryCharge = deliveryData.getDeliveryCharge1(sum); //jugad
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: Padding(
  //       padding: const EdgeInsets.only(top: 8.0),
  //       child: Text(
  //         (cartData.getAmount(widget.serviceId) + deliveryCharge).toString(),
  //         style: theme.textTheme.titleLarge
  //             .copyWith(fontSize: 18, decoration: TextDecoration.overline),
  //       ),
  //     ),
  //   );
  // }
}
