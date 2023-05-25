import 'package:flutter/material.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({Key key}) : super(key: key);

  Widget _getEmptyIcon(ThemeData theme) => Icon(
        Icons.remove_shopping_cart,
        size: 60,
        color: theme.primaryColor,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cart"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getEmptyIcon(theme),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Unfortunately, Your Cart Is Empty",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Please Add Something In Your Cart',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: const Text('Continue Ordering'),
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => !route.navigator.canPop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
