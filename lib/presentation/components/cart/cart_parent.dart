import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/service_model.dart';
import '../../../application/cart.dart';
import '../../../application/services.dart';
import 'cart_service.dart';

// ignore: must_be_immutable
class CartParentComponent extends StatefulWidget {
  List<String> serviceIds = [];
  List<String> services = [];
  Map<String, Map<String, int>> fetchServiceMap = {};
  String parentId;

  CartParentComponent(
      this.serviceIds, this.services, this.parentId, this.fetchServiceMap,
      {Key key})
      : super(key: key);

  @override
  CartParentComponentState createState() => CartParentComponentState();
}

class CartParentComponentState extends State<CartParentComponent> {
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final serviceData = Provider.of<ServiceProvider>(context, listen: false);
    int f = 0; //variable for entering something only once
    int i = 0; //for eg. at i=0 flatCleaning

    final node = serviceData.getParentInfo(widget.serviceIds[i]);
    final theme = Theme.of(context);

    if (cartData.items != null) {
      if (cartData == null) {
        setState(() {});
      }
      num minAmount = serviceData.getParentMinAmount(widget.parentId);
      num totalAmount = cartData.getAmountByParentId(widget.parentId) +
          cartData.deliveryChargesMap[widget.parentId];
      return Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((22)),
            border: Border.all(color: Colors.blue[800])),
        child: ExpansionTile(
            title: node is MultiServiceModel
                ? Row(
                    children: [
                      Text(
                        '${node.parentName} ',
                        style: theme.textTheme.titleLarge.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      minAmount >= totalAmount
                          ? Text(
                              '(Min : Rs.$minAmount)',
                              style: theme.textTheme.titleLarge.copyWith(
                                fontSize: 15,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  )
                : node is SingleServiceModel
                    ? Text(
                        node.serviceName,
                        style: theme.textTheme.titleLarge.copyWith(
                          fontSize: 18,
                        ),
                      )
                    : minAmount >= totalAmount
                        ? Text(
                            '(Min : Rs.$minAmount)',
                            style: theme.textTheme.titleLarge.copyWith(
                              fontSize: 15,
                            ),
                          )
                        : const SizedBox(),
            children: [
              Column(
                children: widget.serviceIds
                    .map((item) => CheckoutServiceItem(item))
                    .toList(),
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Subtotal',
                    style: theme.textTheme.titleMedium.copyWith(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    '${cartData.getAmountByParentId(widget.parentId)}',
                    style: theme.textTheme.titleMedium.copyWith(),
                  ),
                ),
              ]),
              Column(
                children: widget.serviceIds.map((item) {
                  if (f == 0) {
                    f = 1;
                    return _getservicecharge(item, cartData, theme);
                  } else {
                    return Container();
                  }
                }).toList(),
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Grand Total',
                    style: theme.textTheme.titleMedium.copyWith(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    '${cartData.getAmountByParentId(widget.parentId) + cartData.deliveryChargesMap[widget.parentId]}',
                    style: theme.textTheme.titleMedium.copyWith(),
                  ),
                ),
              ]),
              const SizedBox(height: 7)
            ]),
      );
    } else {
      return Container(
        color: Colors.red,
        height: 100,
      );
    }
  }

  Widget _getservicecharge(serviceId, CartProvider cartData, ThemeData theme) {
    final deliveryCharge = cartData.deliveryChargesMap[widget.parentId];
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Text(
            'Service Charges',
            style: theme.textTheme.titleMedium.copyWith(
              decoration:
                  deliveryCharge == 0 ? TextDecoration.lineThrough : null,
            ),
          ),
          IconButton(
            alignment: Alignment.topLeft,
            color: theme.primaryColor,
            icon: const Icon(
              Icons.info,
              size: 15,
            ),
            onPressed: () => _showDeliveryPrices(context, widget.parentId),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              deliveryCharge.toString(),
              style: theme.textTheme.titleMedium.copyWith(
                decoration:
                    deliveryCharge == 0 ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeliveryPrices(BuildContext context, String parId) {
    List<String> serviceKey = widget.fetchServiceMap[parId].keys.toList();
    List<int> serviceValue = widget.fetchServiceMap[parId].values.toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Service Charges',
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: 170,
          width: 240,
          child: ListView.builder(
            itemCount: widget.fetchServiceMap[parId].length,
            itemBuilder: (ctx, index) => ListTile(
              title: index < widget.fetchServiceMap[parId].length - 1
                  ? Text(
                      'SubTotal upto ${int.parse(serviceKey[index + 1]) - 1}')
                  : Text('SubTotal above ${int.parse(serviceKey[index]) - 1}'),
              trailing: Text('Rs ${serviceValue[index]}'),
            ),
          ),
        ),
      ),
    );
  }
}
