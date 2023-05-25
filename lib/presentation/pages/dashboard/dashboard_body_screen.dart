import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../../presentation/pages/dashboard/home/home_screen.dart';
import '../../../presentation/pages/dashboard/order/order_screen.dart';
import 'account/account_screen.dart';

class DashboardBodyScreen extends StatefulWidget {
  const DashboardBodyScreen({Key key}) : super(key: key);

  @override
  DashboardBodyScreenState createState() => DashboardBodyScreenState();
}

class DashboardBodyScreenState extends State<DashboardBodyScreen> {
  Widget _child;

  @override
  void initState() {
    _child = const HomeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: FluidNavBar(
          icons: [
            FluidNavBarIcon(
              icon: Icons.home,
              extras: {"label": "Home"},
            ),
            FluidNavBarIcon(
              icon: Icons.shopping_basket,
              extras: {"label": "Orders"},
            ),
            FluidNavBarIcon(
              icon: Icons.account_balance_wallet,
              extras: {"label": "Payment"},
            ),
            FluidNavBarIcon(
              icon: Icons.account_circle,
              extras: {"label": "Account"},
            ),
          ],
          onChange: _handleNavigationChange,
          style: FluidNavBarStyle(
            barBackgroundColor: theme.primaryColor,
            iconBackgroundColor: theme.primaryColor,
            iconSelectedForegroundColor: Colors.white,
            iconUnselectedForegroundColor: Colors.black,
          ),
          defaultIndex: 0,
          itemBuilder: (icon, item) => Semantics(
            label: icon.extras["label"],
            child: item,
          ),
        ),
        body: _child,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = const HomeScreen();
          break;
        case 1:
          _child = const OrderScreen();
          break;
        case 2:
          _child = Container();
          break;
        case 3:
          _child = const AccountScreen();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}
