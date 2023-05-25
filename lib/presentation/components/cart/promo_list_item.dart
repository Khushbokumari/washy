// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../domain/promocode_model.dart';
import '../../../application/orders.dart';
import '../../../application/services.dart';
import '../error_alert_dialog.dart';

class PromoListItem extends StatefulWidget {
  final PromoCodeModel item;
  final bool isActive;

  const PromoListItem(this.item, this.isActive, {Key key}) : super(key: key);

  @override
  PromoListItemState createState() => PromoListItemState();
}

class PromoListItemState extends State<PromoListItem> {
  bool expanded = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 10,
        shadowColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.blue, width: 3.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getPromoCodeTitle(theme),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                _descriptionText,
                style: theme.textTheme.titleMedium.copyWith(wordSpacing: 1.0),
              ),
            ),
            if (expanded) ...termsAndConditions,
          ],
        ),
      ),
    );
  }

  String get _descriptionText {
    var item = widget.item;
    String response;
    response =
        'Use code ${item.name} and get ${item.discountPercentage}% off upto Rs.${item.maxLiability}';
 response += ' on ${item.maxUsage} orders\n';
    var serviceData = Provider.of<ServiceProvider>(context, listen: false);
    item.minCartAmount.forEach((serviceId, minAmount) {
      if (item.type == "parent") {
        response +=
            '[ ${serviceData.getParentName(item.minCartAmount.keys.toList()[0])} : Minimum Order Rs.$minAmount ]\n';
      } else if (item.type == "product") {
        response +=
            '[ ${serviceData.getProductName(item.minCartAmount.keys.toList()[0])} : Minimum Order Rs.$minAmount ]\n';
      } else {
        response +=
            '[ ${serviceData.getServiceName(serviceId)} : Minimum Order Rs.$minAmount ]\n';
      }
    });
    return response;
  }

  List<Widget> get termsAndConditions {
    var theme = Theme.of(context);
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          '~ Terms & Conditions Apply :-',
          style: theme.textTheme.titleMedium,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 25, top: 8.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The maximum discount to avail is Rs.${widget.item.maxLiability}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            if (widget.item.maxUsage != null)
              Text(
                'Offer valid ${widget.item.maxUsage} per user',
                style: theme.textTheme.titleMedium,
              ),
            if (widget.item.maxUsage != null)
              const SizedBox(
                height: 10,
              ),
            Text(
              'Other T&C\'s may apply',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Offer valid till ${DateFormat.yMMMd().add_jm().format(widget.item.endDate)}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      )
    ];
  }

  Widget _getPromoCodeTitle(ThemeData theme) => ListTile(
        leading: IconButton(
          color: theme.primaryColor,
          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () {
            setState(() {
              expanded = !expanded;
            });
          },
        ),
        title: Text(
          widget.item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: TextButton(
          onPressed: widget.isActive && !loading
              ? () async {
                  try {
                    var orderData = Provider.of<Orders>(context, listen: false);
                    setState(() {
                      loading = true;
                    });
                    DateTime lastApplied =
                        await orderData.getLastApplied(widget.item.id);
                    if (lastApplied
                            .add(Duration(hours: widget.item.coolDownHours))
                            .isAfter(DateTime.now())) {
                      setState(() {
                        loading = false;
                      });
                      _showToast(
                          'This code can be used once in ${widget.item.coolDownHours} hours.');
                    } else if (orderData.getTimesApplied(widget.item.id) >=
                        widget.item.maxUsage) {
                      setState(() {
                        loading = false;
                      });
                      _showToast('Already used maximum number of times');
                    } else {
                      orderData.addPromoCodeToCurrentOrder(
                          widget.item.minCartAmount.keys.toList()[0]);
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => ErrorAlertDialog(
                        title: 'Error',
                        content: 'Network Error',
                        actionTitle: 'Okay',
                        onPressed: () {
                          setState(() {
                            loading = false;
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    );
                  }
                }
              : null,
          child: loading
              ? const Text('Applying..')
              : const Text(
                  'Apply',
                  style: TextStyle(fontSize: 16),
                ),
        ),
        subtitle: Text(
          'Get ${widget.item.discountPercentage}% discount.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  _showToast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
    // Scaffold.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(text),
    //   ),
    // );
  }
}
