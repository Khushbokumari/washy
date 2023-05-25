import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalTNCScreen extends StatelessWidget {
  static const String routeName = 'Legal-Tnc-Screen';

  const LegalTNCScreen({Key ?key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal'),
        ),
        body: ListView(
          children: <Widget>[
            ExpansionTile(
              title: const Text('Terms of Use'),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: theme.primaryColor,
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Washry is pleased to provide professional pick-up and delivery laundry services to its customers and offers quality and convenience at an affordable price. We offer you, our customers, our services subject to your compliance with and acceptance of the terms and conditions stated and set forth below. Your use of Washry services (“Services”) indicates your agreement to be bound by the terms and conditions contained herein. By using our service, you agree that your clothes are appropriate for washing with water, on a normal cycle, and tumble-dried in a dryer. We cannot be held responsible for damage to clothing/laundry that is not appropriate for this standard laundering process. Please read the following provisions carefully and if you do not agree, please do not use the services. These terms and conditions are applicable on orders placed either via website or call or our app.",
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Privacy Policy'),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: theme.primaryColor,
              ),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "We reserve the right to modify this privacy policy at any time, so please review it frequently. Changes and clarifications will take effect immediately upon their posting on the website. If we make material changes to this policy, we will notify you here that it has been updated, so that you are aware of what information we collect, how we use it, and under what circumstances, if any, we use and/or disclose it. If our store is acquired or merged with another company, your information may be transferred to the new owners so that we may continue to sell products to you."),
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "For More Details",
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse('https://washry.in/privacy-policy/')),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Refund Policy'),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: theme.primaryColor,
              ),
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "If Customer wants to Cancel Pickup request before pickup then write a cancel request on washrycleaning@gmail.com. Once the order is picked up it cannot be cancelled or Refund. Washry reserve the right to cancel the pick-up and delivery, if the customer does not reach the place of pick-up and delivery within 15 minutes of Washry representative reaching the customer premises without notifying the customer. In case of any loss or damage of any garment, Washry has to be notified within 24 hours of delivery. We shall not be responsible of any claims post 24 hours of delivery of the order. If the user wishes to request for refund of an order, the user shall drop an email at washrycleaning@gmail.com with the order number requesting for refund. If the customer sending a refund request to Washry, Customer required to email Washry with the images of defective product at washrycleaning@gmail.com along with Customer details including Name, Address and order Id. It will take minimum of 15 days for reverting back. Company/ Website/App is not obliged to attempt redelivery more than twice. If user is not available to accept redelivery a second time, items will be returned to Company/ Website’s service provider and user will be notified accordingly by phone or email. Subsequent redelivery will be at user’s expense. If user has failed to accept or arrange redelivery of an order for more than 30 days after the redelivery date specified in the order, Washry does not assume any liability whatsoever. In case of any damage to the clothes or loss of clothes the company shall refund 25% of the cost of such clothes to the maximum of Rs. 2,000/ (Rupees Two thousand) provided the user produces a valid/original receipt reflecting the price of the clothes and proof of damage or loss by Wash. Please Read all terms and Conditions carefully before ask for Refund. Though we ensure that all your clothes are delivered without any loss or damage but in case any damage or loss happens, Washry reserves the complete right to determine the compensation to be paid to the claimant.",
                    style: TextStyle(fontSize: 15, wordSpacing: 0.4),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
