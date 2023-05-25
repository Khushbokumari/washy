import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/cart_model.dart';
import '../../../application/cart.dart';

class CartProductComponent extends StatelessWidget {
  final CartModel cartItem;
  final String serviceId, productId;

  const CartProductComponent({
    Key key,
    @required this.cartItem,
    @required this.serviceId,
    @required this.productId,
  }) : super(key: key);

  String get _titleName => '${cartItem.title} (${cartItem.categoryName}) ';

  String get _quantity => cartItem.quantity.toString();

  String get _total => '${cartItem.price * cartItem.quantity}';

  Widget _getRemoveIconButton(CartProvider cartData, ThemeData theme) =>
      InkWell(
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.rectangle,
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                "_",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        onTap: () => cartData.updateCart(
          serviceId: serviceId,
          productId: productId,
          cartItem: CartModel(
            categoryName: cartItem.categoryName,
            serviceName: cartItem.serviceName,
            id: cartItem.id,
            quantity: cartItem.quantity - 1,
            price: cartItem.price,
            title: cartItem.title,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * .45,
            child: Text(
              _titleName,
              style: theme.textTheme.titleMedium.copyWith(
                fontSize: 14,
              ),
            ),
          ),
          _getRemoveIconButton(cartData, theme),
          Text(
            _quantity,
            style: theme.textTheme.titleMedium.copyWith(
              fontSize: 16,
            ),
          ),
          _getAddIconButton(cartData, theme),
          const Spacer(),
          Text(
            _total,
            style: theme.textTheme.titleMedium.copyWith(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAddIconButton(CartProvider cartData, ThemeData theme) =>
      IconButton(
        color: theme.primaryColor,
        icon: const Icon(
          Icons.add_box_rounded,
          size: 20,
        ),
        onPressed: () => cartData.updateCart(
          serviceId: serviceId,
          productId: productId,
          cartItem: CartModel(
            categoryName: cartItem.categoryName,
            serviceName: cartItem.serviceName,
            id: cartItem.id,
            quantity: cartItem.quantity + 1,
            price: cartItem.price,
            title: cartItem.title,
          ),
        ),
      );
}
