import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washry/domain/category_model.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/services.dart';
import '../../../presentation/components/cart/bottom_cart_total_display.dart';
import '../../../presentation/components/cart/cart_icon_button.dart';
import '../../components/home/services/custom_category_tab_list.dart';
import '../../components/home/services/custom_tab.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = 'cart-screen';

  const CartScreen({Key key}) : super(key: key);
  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  String serviceId;
  String parentId;
  bool init = true;
  List<Category> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      init = false;
      serviceId = ModalRoute.of(context).settings.arguments;
      categories = Provider.of<ServiceProvider>(context, listen: false)
          .getCategories(serviceId);
    }
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
          bottomNavigationBar: const BottomCartTotalDisplay(),
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
        actions: const [CartIconButton()],
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

  List<Widget> get _tabList =>
      categories.map((item) => CategoryTabList(serviceId, item)).toList();
}
