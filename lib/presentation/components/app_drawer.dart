import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/auth.dart';
import '../../presentation/pages/checkout/checkout_screen.dart';
import '../../presentation/pages/auth/login_screen.dart';
import '../../presentation/pages/dashboard/order/order_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          Consumer<AuthProvider>(
            builder: (ctx, auth, child) {
              return FutureBuilder<bool>(
                future: auth.isAuth(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return snapshot.data
                        ? ListTile(
                            title: const Text(
                              'Logout',
                            ),
                            leading: const Icon(Icons.exit_to_app),
                            onTap: () {
                              Navigator.of(context).pop();
                              auth.logout();
                            },
                          )
                        : ListTile(
                            title: const Text(
                              'Login',
                            ),
                            leading: const Icon(Icons.person),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
                            },
                          );
                  }
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text(
              'Cart',
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(CheckoutScreen.routeName);
            },
          ),
          const Divider(),
          Consumer<AuthProvider>(
            builder: (ctx, auth, child) {
              return FutureBuilder<bool>(
                future: auth.isAuth(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return snapshot.data
                        ? ListTile(
                            title: const Text(
                              'Order',
                            ),
                            leading: const Icon(Icons.payment),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pushNamed(OrderScreen.routeName);
                            },
                          )
                        : const SizedBox();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
