import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/services.dart';

import '../../../../../domain/category_model.dart';
import '../../../../components/cart/bottom_cart_total_display.dart';
import '../../../../components/home/services/custom_category_tab_list.dart';
import '../../../../components/home/services/custom_tab.dart';

class ServiceProductScreen extends StatefulWidget {
  static const String routeName = 'service-product-screen';

  const ServiceProductScreen({Key key}) : super(key: key);
  @override
  ServiceProductScreenState createState() => ServiceProductScreenState();
}

class ServiceProductScreenState extends State<ServiceProductScreen> {
  String serviceId;
  bool init = true;
  List<Category> categories;

  @override
  void didChangeDependencies() {
    if (init) {
      init = false;
      serviceId = ModalRoute.of(context).settings.arguments;
      categories = Provider.of<ServiceProvider>(context, listen: false)
          .getCategories(serviceId);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          appBar: _appbar,
          body: TabBarView(
            children: _tabList,
          ),
          floatingActionButton: const BottomCartTotalDisplay(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  Widget get _appbar => AppBar(
        title: FittedBox(
          child: Text(
            Provider.of<ServiceProvider>(context, listen: false)
                .getServiceName(serviceId),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        bottom: TabBar(
          isScrollable: true,
          tabs: categories.map((item) {
            return Tab(
              child: Consumer<CartProvider>(
                builder: (ctx, cartData, child) => CountTab(
                  item.categoryName,
                  cartData.getItemCountByCategoryAndService(
                    item.categoryName,
                    serviceId,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  List<Widget> get _tabList => categories
      .map((category) => CategoryTabList(serviceId, category))
      .toList();
}
