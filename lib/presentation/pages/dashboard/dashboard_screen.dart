import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/cart.dart';
import '../../../application/locations.dart';
import 'dashboard_body_screen.dart';
import '../first_landing_page.dart';
import '../location/location_search_screen.dart';
import '../splash_screen.dart';
import '../../components/error_alert_dialog.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = 'dashboard-screen';

  const DashboardScreen({Key key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  Future _preLoadingFuture;

  @override
  void initState() {
    super.initState();
    _preLoadingFuture = _doPreAppStartLoading(context);
  }

  Future<void> _doPreAppStartLoading(BuildContext context) async {
    if (!await _tryToGetLocation()) exit(0);
    await Provider.of<CartProvider>(context, listen: false).refreshSlotsDate();
    await Provider.of<CartProvider>(context, listen: false).loadCart();
    await Provider.of<LocationProvider>(context, listen: false)
        .getLocationsFromServer();
  }

  Future<bool> _tryToGetLocation() async {
    bool locationAlreadySavedInDevice =
        await Provider.of<LocationProvider>(context, listen: false)
            .hasSavedLocation();
    if (!locationAlreadySavedInDevice) {
      if ((await Navigator.of(context).pushNamed(FirstLandingPage.routeName)) !=
          true) exit(0);
      var didUserChooseLocation = await Navigator.of(context)
          .pushNamed(LocationSearchScreen.routeName, arguments: true);
      if (didUserChooseLocation != true) return false;
    }
    return true;
  }

  Widget _errorAlert(Object e) => ErrorAlertDialog(
        onPressed: () => Navigator.of(context)
            .pushReplacementNamed(DashboardScreen.routeName),
        title: 'Error',
        content: 'No internet connection',
        actionTitle: 'Retry',
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _preLoadingFuture,
      builder: (ctx, snapshot) {
        return snapshot.hasError
            ? _errorAlert(snapshot.error)
            : snapshot.connectionState == ConnectionState.waiting
                ? const SplashScreen()
                : const DashboardBodyScreen();
      },
    );
  }
}
