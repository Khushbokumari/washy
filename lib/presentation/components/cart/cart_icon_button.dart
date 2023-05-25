import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/cart.dart';
import '../../../presentation/pages/checkout/checkout_screen.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Consumer<CartProvider>(
        builder: (ctx, cartData, child) => cartData.totalQuantity == 0
            ? const Icon(Icons.shopping_cart)
            : Badge(
                label: Text(cartData.totalQuantity.toString()),
                textColor: Colors.black,
                child: const Icon(Icons.shopping_cart),
              ),
      ),
      onPressed: () =>
          Navigator.of(context).pushNamed(CheckoutScreen.routeName),
    );
  }
}
