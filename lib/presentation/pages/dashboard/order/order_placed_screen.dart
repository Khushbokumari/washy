import 'package:flutter/material.dart';
import 'order_screen.dart';

class OrderPlacedScreen extends StatelessWidget {
  static const String routeName = 'Order-Placed-Screen';

  const OrderPlacedScreen({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Placed'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/app_logo.png'),
                radius: 100,
              ),
              const SizedBox(height: 25),
              const Text(
                'Order Placed Sucessfully!!!',
                style: TextStyle(color: Colors.blue, fontSize: 25),
              ),
              const SizedBox(height: 12),
              const Text(
                'Thanks for placing the order.',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'View Orders Details',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => !route.navigator.canPop());
                    Navigator.of(context).pushNamed(OrderScreen.routeName);
                  }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
