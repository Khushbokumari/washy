import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/pages/auth/login_screen.dart';
import '../../application/auth.dart';

class FirstLandingPage extends StatelessWidget {
  static const String routeName = 'First-Landing-Page';

  const FirstLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.fill,
                  width: mediaQuery.size.width * .9,
                  height: mediaQuery.size.height * .5,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(LoginScreen.routeName)
                      .then((_) async {
                    if (await Provider.of<AuthProvider>(context, listen: false)
                        .isAuth()) Navigator.of(context).pop(true);
                  }),
                  child: Text('Login'.toUpperCase()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Set Location'.toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
