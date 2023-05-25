import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ServiceNonActiveStatus extends StatelessWidget {
  String serviceName, serviceMessage;

  ServiceNonActiveStatus(
      {Key key, @required this.serviceMessage, @required this.serviceName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(serviceName),
        ),
        body: SizedBox(
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "We will be resuming this service soon",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/serviceResume.jpg',
                height: size.height / 3,
              ),
              const SizedBox(
                height: 10,
              ),
              serviceMessage != ""
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        serviceMessage,
                        overflow: TextOverflow.clip,
                      ),
                    )
                  : Container(),
              ElevatedButton(
                onPressed: () {
                  _launchWhatsApp();
                },
                child: const Text("Notify Me"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    String phoneNumber = '+918079013893';
    String message =
        'Hello, Please Notify me Whenever $serviceName services will be operational.';
    var whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }
}
