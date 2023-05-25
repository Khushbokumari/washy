import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../components/cart/cart_icon_button.dart';

class NotLoggedInScreen extends StatelessWidget {
  final String title;

  const NotLoggedInScreen(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [CartIconButton()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are not logged in',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('Goto Login page'),
              onPressed: () => Navigator.of(context).pushNamed(
                LoginScreen.routeName,
              ),
            )
          ],
        ),
      ),
    );
  }
}
