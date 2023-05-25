import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../application/auth.dart';
import '../../../../presentation/pages/dashboard/account/profile_screen.dart';
import '../../address/select_address_screen.dart';
import '../../auth/not_logged_in_screen.dart';
import 'legal/contact_screen.dart';
import 'legal/legal_tnc_screen.dart';
import '../../wallet/wallet_screen.dart';
import '../order/order_screen.dart';
import '../../../components/cart/cart_icon_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String uid = FirebaseAuth.instance.currentUser.uid;
    return Consumer<AuthProvider>(
      builder: (ctx, authData, _) {
        return FutureBuilder<bool>(
          future: authData.isAuth(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return snapshot.data
                  ? SafeArea(
                      child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Account'),
                        actions: const [CartIconButton()],
                      ),
                      body: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 250,
                                width: 250,
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.location_on),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('Saved Addresses'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context).pushNamed(
                                    SelectAddressScreen.routeName,
                                    arguments: true),
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.person),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('Your Profile'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(ProfileScreen.routeName),
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.local_mall),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('My Orders'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(OrderScreen.routeName),
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.assignment),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('Legal'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(LegalTNCScreen.routeName),
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.wallet_giftcard),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('Wallet'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(WalletScreen.routeName),
                              ),
                              ListTile(
                                leading: Icon(
                                  (Icons.mail_outline),
                                  color: theme.primaryColor,
                                ),
                                title: const Text('Contact Us'),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: theme.primaryColor,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(ContactUsScreen.routeName),
                              ),
                              ListTile(
                                  leading: Icon(
                                    (Icons.launch),
                                    color: theme.primaryColor,
                                  ),
                                  title: const Text('Logout'),
                                  trailing: Icon(
                                    Icons.power_settings_new,
                                    color: theme.primaryColor,
                                  ),
                                  onTap: () {
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .logout();
                                  }),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Referral code : ${uid.substring(0, 4)}',
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .02,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: uid.substring(0, 4)));
                                            },
                                            child: const Icon(Icons.copy))
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ))
                  : const NotLoggedInScreen('Account');
            }
          },
        );
      },
    );
  }
}
