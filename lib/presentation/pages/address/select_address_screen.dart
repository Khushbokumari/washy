import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/network/url.dart';
import '../../../core/utils/location_math.dart';
import 'package:washry/domain/address_model.dart';
import 'package:washry/domain/service_model.dart';
import 'package:washry/application/address.dart';
import 'package:washry/application/auth.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/locations.dart';
import 'package:washry/application/orders.dart';
import 'package:washry/application/serviceIds.dart';
import 'package:washry/application/services.dart';
import '../../../presentation/pages/address/add_address_screen.dart';
import '../../../presentation/pages/auth/login_screen.dart';
import '../../../presentation/pages/order_handeling/pickup_select_screen.dart';
import '../../../presentation/components/error_alert_dialog.dart';
import '../../../presentation/components/shimmer_loading_list.dart';
import 'package:http/http.dart' as http;

class SelectAddressScreen extends StatefulWidget {
  static const routeName = "Select-Address-Screen";

  const SelectAddressScreen({Key key}) : super(key: key);

  @override
  SelectAddressScreenState createState() => SelectAddressScreenState();
}

class SelectAddressScreenState extends State<SelectAddressScreen> {
  Future _addressLoadFuture;
  bool displayOnly;

  @override
  void initState() {
    super.initState();
    _addressLoadFuture = Provider.of<AddressProvider>(context, listen: false)
        .fetchAndSetAddress();
  }

  Widget _errorAlert() => ErrorAlertDialog(
        onPressed: () => Navigator.of(context).pop(),
        title: 'Error',
        content: 'No internet connection',
        actionTitle: 'Retry',
      );

  @override
  Widget build(BuildContext context) {
    displayOnly =
        ModalRoute.of(context).settings.arguments == null ? false : true;
    return Consumer<AuthProvider>(
      builder: (ctx, authData, child) {
        return FutureBuilder<bool>(
          future: authData.isAuth(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.data) {
                return FutureBuilder(
                  future: _addressLoadFuture,
                  builder: (ctx, snapshot) => snapshot.hasError
                      ? _errorAlert
                      : snapshot.connectionState == ConnectionState.waiting
                          ? const SafeArea(
                              child: Scaffold(body: ShimmerLoadingList()))
                          : SafeArea(
                              child: Scaffold(
                                appBar: AppBar(
                                  title: displayOnly
                                      ? const Text('Your Addresses')
                                      : const Text('Select Address'),
                                ),
                                body: _PageBody(
                                  displayOnly: displayOnly,
                                ),
                              ),
                            ),
                );
              } else {
                Navigator.of(context).popUntil((route) =>
                    route.settings.name == SelectAddressScreen.routeName);
                return ErrorAlertDialog(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(LoginScreen.routeName),
                  content: 'You are not logged in!',
                  title: 'Login Error',
                  actionTitle: 'Goto login page',
                );
              }
            }
          },
        );
      },
    );
  }
}

class _PageBody extends StatefulWidget {
  final bool displayOnly;

  const _PageBody({Key key, @required this.displayOnly}) : super(key: key);

  @override
  __PageBodyState createState() => __PageBodyState();
}

class __PageBodyState extends State<_PageBody> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isLoading == true
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () =>
                Provider.of<AddressProvider>(context, listen: false)
                    .fetchAndSetAddress(true),
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  title: Text(
                    'Add a new address',
                    style: theme.textTheme.titleMedium
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AddAddressScreen.routeName),
                ),
                const Divider(
                  color: Colors.blue,
                  thickness: 2.0,
                ),
                ..._getListOfAddresses(context),
              ],
            ),
          );
  }

  List<Widget> _getListOfAddresses(BuildContext context) {
    var svcIds = Provider.of<ServiceIds>(context, listen: false);
    final locationData = Provider.of<LocationProvider>(context, listen: false);
    final addressData = Provider.of<AddressProvider>(context);

    var servicesProvier = Provider.of<ServiceProvider>(context);
    List<String> par = [];

    for (var element in svcIds.serviceId) {
      ServiceModel temp = servicesProvier.getParentInfo(element);
      if (temp is MultiServiceModel) {
        if (!par.contains(temp.parentId)) {
          par.add(temp.parentId);
        }
      } else if (temp is SingleServiceModel) {
        if (!par.contains(temp.serviceId)) {
          par.add(temp.serviceId);
        }
      }
    }
    svcIds.updateParentIds(par);

    return [
      if (addressData.addresses.isNotEmpty)
        const ListTile(
          title: Text('Saved Addresses'),
        ),
      ...addressData.addresses
          .map(
            (item) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
              child: ListTile(
                onTap: widget.displayOnly
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        await _addressItemTapCallback(
                            context, item, locationData, par);
                        setState(() {
                          isLoading = false;
                        });
                      },
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.place,
                    color: Colors.blue,
                  ),
                ),
                isThreeLine: true,
                title: Text(
                  item.contactName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      onPressed: () => _editAddressCallback(context, item.id),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.blue,
                      ),
                      onPressed: () =>
                          _removeAddressCallback(context, item.id, addressData),
                    ),
                  ],
                ),
                subtitle: Text(
                  item.formattedAddress,
                ),
                horizontalTitleGap: 2.0,
              ),
            ),
          )
          .toList(),
    ];
  }

  Future<void> refreshSlotsDate(BuildContext context) async {
    DateTime date = DateTime.now();
    const urll =
        "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22.json";
    final response = await http.get(Uri.parse(urll));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData["refresh"] != date.day) {
      const urll =
          "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22.json";

      await http.patch(Uri.parse(urll),
          body: jsonEncode({"refresh": date.day}));
      responseData["services"].forEach((parId, value) {
        if (value["isOneTimeService"] == false) {
          value["delivery"]["del"].forEach((key, value) async {
            final urll = "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parId/delivery/del/$key.json";
            await http.patch(Uri.parse(urll),
                body: jsonEncode({
                  "availableSlots": value["maxSlots"],
                }));
          });
          value["delivery"]["slots"].forEach((key, value) async {
            final urll = "${URL.LOCATION_DATABASE_URL}/PQbUolFy3Oglow9y4zTGtieHcp22/services/$parId/delivery/slots/$key.json";
            await http.patch(Uri.parse(urll),
                body: jsonEncode({"availableSlots": value["maxSlots"]}));
          });
        }
      });

      await Provider.of<CartProvider>(context, listen: false).loadCart();
    }
  }

  int x = 0;

  _addressItemTapCallback(BuildContext context, AddressModel item,
      LocationProvider locationData, List<String> par) async {
    final svcId = Provider.of<ServiceIds>(context, listen: false);
    svcId.availableSlotsMap = {};
    svcId.availabledelSlotsMap = {};
    if (LocationMath.isInsideRadius(
        locationData.currentOperationLocation, LatLng(item.lat, item.lng))) {
      Provider.of<Orders>(context, listen: false)
          .addAddressToCurrentOrder(item);
      isLoading = false;
      Navigator.of(context).pushNamed(PickupSelectScreen.routeName);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry :(  We do not serve in this location.'),
        ),
      );
    }
  }

  Future<void> _removeAddressCallback(
      BuildContext ctx, String id, AddressProvider addressData) async {
    return showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.lightBlue, width: 2.0),
        ),
        content: const Text('Are you sure want to delete ?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  await addressData.removeAddress(id);
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  _editAddressCallback(BuildContext context, String id) {
    Navigator.of(context).pushNamed(AddAddressScreen.routeName, arguments: id);
  }
}
