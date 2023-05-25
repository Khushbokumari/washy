// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'application/serviceChargeProvider.dart';
// import 'application/serviceIds.dart';
// import 'presentation/pages/auth/parentInfo.dart';
// import 'presentation/pages/dashboard/account/profile_screen.dart';
// import 'presentation/pages/wallet/wallet_screen.dart';
// import 'presentation/pages/dashboard/order/order_details_screen.dart';
// import 'presentation/pages/dashboard/home/services/services_list_screen.dart';
// import 'application/address.dart';
// import 'application/auth.dart';
// import 'application/banners.dart';
// import 'application/cart.dart';
// import 'application/delivery.dart';
// import 'application/locations.dart';
// import 'application/orders.dart';
// import 'application/promos.dart';
// import 'application/services.dart';
// import 'presentation/pages/address/add_address_screen.dart';
// import 'presentation/pages/cart/cart_screen.dart';
// import 'presentation/pages/checkout/checkout_screen.dart';
// import 'presentation/pages/first_landing_page.dart';
// import 'presentation/pages/dashboard/account/legal/contact_screen.dart';
// import 'presentation/pages/location/location_search_screen.dart';
// import 'presentation/pages/dashboard/dashboard_screen.dart';
// import 'presentation/pages/dashboard/account/legal/legal_tnc_screen.dart';
// import 'presentation/pages/location/location_select_screen.dart';
// import 'presentation/pages/auth/login_screen.dart';
// import 'presentation/pages/dashboard/order/order_screen.dart';
// import 'presentation/pages/payment/payment_screen.dart';
// import 'presentation/pages/order_handeling/pickup_select_screen.dart';
// import 'presentation/pages/checkout/promocode_screen.dart';
// import 'presentation/pages/address/select_address_screen.dart';
//
// main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key ?key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (ctx) => LocationProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (ctx) => AuthProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (ctx) => CartProvider(),
//         ),
//         ChangeNotifierProvider(
//           create: (ctx) => ServiceIds(),
//         ),
//         ProxyProvider<LocationProvider, BannerProvider>(
//           create: (ctx) => BannerProvider('', []),
//           update: (ctx, value, _) => BannerProvider(
//             value.currentOperationLocation!.locationId,
//             value.currentOperationLocation!.banners,
//           ),
//         ),
//         ProxyProvider<LocationProvider, ServiceProvider>(
//           create: (ctx) => ServiceProvider('', []),
//           update: (ctx, value, _) => ServiceProvider(
//             value.currentOperationLocation!.locationId,
//             value.currentOperationLocation!.services,
//           ),
//         ),
//         ProxyProvider<LocationProvider, SlotProvider>(
//           create: (ctx) => SlotProvider('', {}, [], {}, {}, {}),
//           update: (ctx, value, _) => SlotProvider(
//             value.currentOperationLocation!.locationId,
//             value.currentOperationLocation!.deliveryCharges,
//             value.currentOperationLocation!.deliverySlots,
//             value.currentOperationLocation!.slotsDelivery,
//             value.currentOperationLocation!.priceDelivery,
//             value.currentOperationLocation!.delDelivery,
//           ),
//         ),
//         ProxyProvider<LocationProvider, Promos>(
//           create: (ctx) => Promos('', [], {}),
//           update: (ctx, value, prev) => Promos(
//             value.currentOperationLocation!.locationId,
//             value.currentOperationLocation!.promos,
//             value.currentOperationLocation!.promosMap,
//           ),
//         ),
//         ChangeNotifierProxyProvider<AuthProvider, Orders>(
//           create: (ctx) => Orders('', ''),
//           update: (ctx, value, prev) => Orders(value.userId, value.token),
//         ),
//         ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
//           create: (ctx) => AddressProvider('', ''),
//           update: (ctx, value, prev) =>
//               AddressProvider(value.userId, value.token),
//         ),
//         ChangeNotifierProvider(
//           create: (ctx) => ServiceChargeProvider(),
//         ),
//       ],
//       child: MaterialApp(
//         initialRoute: DashboardScreen.routeName,
//         routes: {
//           LoginScreen.routeName: (_) => LoginScreen(),
//           DashboardScreen.routeName: (_) => DashboardScreen(),
//           FirstLandingPage.routeName: (_) =>  FirstLandingPage(),
//           CartScreen.routeName: (_) =>  CartScreen(),
//           LocationSearchScreen.routeName: (_) =>  LocationSearchScreen(),
//           LocationSelectScreen.routeName: (_) =>  LocationSelectScreen(),
//           CheckoutScreen.routeName: (_) =>  CheckoutScreen(),
//           PromoCodeScreen.routeName: (_) =>  PromoCodeScreen(),
//           AddAddressScreen.routeName: (_) =>  AddAddressScreen(),
//           SelectAddressScreen.routeName: (_) =>  SelectAddressScreen(),
//           ProfileScreen.routeName: (_) =>  ProfileScreen(),
//           WalletScreen.routeName: (_) =>  WalletScreen(),
//           PickupSelectScreen.routeName: (_) => PickupSelectScreen(),
//           PaymentScreen.routeName: (_) =>  PaymentScreen(),
//           OrderScreen.routeName: (_) => OrderScreen(),
//           LegalTNCScreen.routeName: (_) =>  LegalTNCScreen(),
//           OrderDetailsScreen.routeName: (_) =>  OrderDetailsScreen(),
//           ContactUsScreen.routeName: (_) =>  ContactUsScreen(),
//           ServiceListScreen.routeName: (_) =>  ServiceListScreen(),
//           ParentInfo.routeName: (_) =>  ParentInfo("Phone Number", false),
//         },
//         title: 'Cleaning Customer App',
//         theme: ThemeData(
//           primaryColor: Colors.blue,
//           buttonTheme: Theme.of(context).buttonTheme.copyWith(
//             buttonColor: Colors.blue,
//             minWidth: 100,
//             height: 40,
//             disabledColor: Colors.blue.withOpacity(.3),
//             textTheme: ButtonTextTheme.primary,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//             ),
//           ),
//           colorScheme:
//           ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
//         ),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'application/address.dart';
import 'application/auth.dart';
import 'application/banners.dart';
import 'application/cart.dart';
import 'application/delivery.dart';
import 'application/locations.dart';
import 'application/orders.dart';
import 'application/promos.dart';
import 'application/services.dart';

import 'presentation/pages/address/add_address_screen.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/cart/cart_screen.dart';
import 'presentation/pages/checkout/checkout_screen.dart';
import 'presentation/pages/checkout/promocode_screen.dart';
import 'presentation/pages/dashboard/account/legal/contact_screen.dart';
import 'presentation/pages/dashboard/account/legal/legal_tnc_screen.dart';
import 'presentation/pages/dashboard/account/profile_screen.dart';
import 'presentation/pages/dashboard/dashboard_screen.dart';
import 'presentation/pages/dashboard/home/services/services_list_screen.dart';
import 'presentation/pages/dashboard/order/order_details_screen.dart';
import 'presentation/pages/dashboard/order/order_screen.dart';
import 'presentation/pages/first_landing_page.dart';
import 'presentation/pages/location/location_search_screen.dart';
import 'presentation/pages/location/location_select_screen.dart';
import 'presentation/pages/order_handeling/pickup_select_screen.dart';
import 'presentation/pages/payment/payment_screen.dart';
import 'presentation/pages/wallet/wallet_screen.dart';

import 'application/serviceChargeProvider.dart';
import 'application/serviceIds.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocationProvider>(
          create: (ctx) => LocationProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider<ServiceIds>(
          create: (ctx) => ServiceIds(),
        ),
        ProxyProvider<LocationProvider, BannerProvider>(
          update: (ctx, locationProvider, previous) =>
              BannerProvider(
                locationProvider.currentOperationLocation?.locationId ?? '',
                locationProvider.currentOperationLocation?.banners ?? [],
              ),
        ),
        ProxyProvider<LocationProvider, ServiceProvider>(
          update: (ctx, locationProvider, previous) =>
              ServiceProvider(
                locationProvider.currentOperationLocation?.locationId ?? '',
                locationProvider.currentOperationLocation?.services ?? [],
              ),
        ),
        ProxyProvider<LocationProvider, SlotProvider>(
          update: (ctx, locationProvider, previous) =>
              SlotProvider(
                locationProvider.currentOperationLocation?.locationId ?? '',
                locationProvider.currentOperationLocation?.deliveryCharges ?? {},
                locationProvider.currentOperationLocation?.deliverySlots ?? [],
                locationProvider.currentOperationLocation?.slotsDelivery ?? {},
                locationProvider.currentOperationLocation?.priceDelivery ?? {},
                locationProvider.currentOperationLocation?.delDelivery ?? {},
              ),
        ),
        ProxyProvider<LocationProvider, Promos>(
          update: (ctx, locationProvider, previous) =>
              Promos(
                locationProvider.currentOperationLocation?.locationId ?? '',
                locationProvider.currentOperationLocation?.promos ?? [],
                locationProvider.currentOperationLocation?.promosMap ?? {},
              ),
        ),
        // ChangeNotifierProxyProvider2<AuthProvider, Orders, Orders>(
        //   create: (ctx) => Orders(),
        //   update: (ctx, authProvider, orders, previous) =>
        //   Orders()
        //     ..userId = authProvider.userId
        //     ..token = authProvider.token
        //     ..orders = previous?.orders ?? [],
        // ),
      ],
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) =>  FirstLandingPage(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          DashboardScreen.routeName: (ctx) => DashboardScreen(),
          LocationSelectScreen.routeName: (ctx) => LocationSelectScreen(),
          LocationSearchScreen.routeName: (ctx) => LocationSearchScreen(),
          ServiceListScreen.routeName: (ctx) => ServiceListScreen(),
          PickupSelectScreen.routeName: (ctx) => PickupSelectScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen(),
          OrderDetailsScreen.routeName: (ctx) => OrderDetailsScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          CheckoutScreen.routeName: (ctx) => CheckoutScreen(),
          PromoCodeScreen.routeName: (ctx) => PromoCodeScreen(),
          PaymentScreen.routeName: (ctx) =>  PaymentScreen(),
          WalletScreen.routeName: (ctx) => WalletScreen(),
          ContactUsScreen.routeName: (ctx) => ContactUsScreen(),
          LegalTNCScreen.routeName: (ctx) => LegalTNCScreen(),
          AddAddressScreen.routeName: (ctx) => AddAddressScreen(),
        },
      ),
    );
  }
}
