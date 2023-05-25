import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../presentation/pages/checkout/checkout_screen.dart';
import '../../../application/cart.dart';

class BottomCartTotalDisplay extends StatelessWidget {
  const BottomCartTotalDisplay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Consumer<CartProvider>(
      builder: (ctx, cartData, child) {
        return cartData.totalAmount > 0
            ? Container(
                color: theme.primaryColor,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Rs ${cartData.totalAmount}/- | ',
                      style: theme.textTheme.titleLarge
                          .copyWith(color: Colors.white),
                    ),
                    Text(
                      '${cartData.totalQuantity} items added',
                      style: theme.textTheme.titleSmall
                          .copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(.1),
                      ),
                      onPressed: () => Navigator.of(context).pushNamed(
                        CheckoutScreen.routeName,
                      ),
                      child: Text(
                        'Next  ->',
                        style: theme.textTheme.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }
}
