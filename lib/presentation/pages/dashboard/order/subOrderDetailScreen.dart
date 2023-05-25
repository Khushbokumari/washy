// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:washry/domain/cart_model.dart';
import 'package:washry/domain/order_item.dart';

class SubOrderDetailScreen extends StatefulWidget {
  String parentId;
  final OrderItem _item;

  SubOrderDetailScreen(this.parentId, this._item, {Key key}) : super(key: key);

  @override
  SubOrderDetailScreenState createState() => SubOrderDetailScreenState();
}

class SubOrderDetailScreenState extends State<SubOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<CartModel> list = widget._item.categoryItems[widget.parentId].items;

    var subtotalByParent =
        widget._item.categoryItems[widget.parentId].categoryAmount.subtotal;
    var deliveryByParent =
        widget._item.categoryItems[widget.parentId].categoryAmount.delivery;
    var discountByParent =
        widget._item.categoryItems[widget.parentId].categoryAmount.discount;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 175,
              child: Card(
                  child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowHeight: 30,
                      columnSpacing: 20,
                      dataRowHeight: 60,
                      columns: const [
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Item Name')),
                        DataColumn(label: Text('Service')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows: list.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item.quantity.toString())),
                          DataCell(
                            SizedBox(
                              width: 150,
                              child:
                                  Text('${item.title} (${item.categoryName})'),
                            ),
                          ),
                          DataCell(Text(item.serviceName)),
                          DataCell(Text(
                              'Rs ${(item.price * item.quantity).toStringAsFixed(0)}')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              )),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Payments',
                        style:
                            theme.textTheme.bodySmall.copyWith(fontSize: 14)),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text('Subtotal',
                            style: theme.textTheme.bodySmall
                                .copyWith(fontSize: 14)),
                        const Spacer(),
                        Text('Rs $subtotalByParent',
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text('Service Charges',
                            style: theme.textTheme.bodySmall
                                .copyWith(fontSize: 14)),
                        const Spacer(),
                        Text('Rs $deliveryByParent',
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Text('Discount',
                            style: theme.textTheme.bodySmall
                                .copyWith(fontSize: 14)),
                        const Spacer(),
                        Text('Rs $discountByParent',
                            style: theme.textTheme.titleLarge
                                .copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text(
                            widget._item.hasPaid
                                ? 'Amount paid via ${widget._item.payment['paymentMode']}'
                                : 'To Be Paid via ${widget._item.payment['paymentMode']}',
                            style: theme.textTheme.titleLarge.copyWith(
                                fontSize: 14, color: theme.primaryColor)),
                        const Spacer(),
                        Text(
                          'Rs ${subtotalByParent + deliveryByParent - discountByParent}',
                          style: theme.textTheme.titleLarge.copyWith(
                              fontSize: 14, color: theme.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
