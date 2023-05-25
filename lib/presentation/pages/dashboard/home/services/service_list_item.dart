import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washry/application/cart.dart';
import 'package:washry/application/services.dart';

import '../../../../../domain/cart_model.dart';
import '../../../../../domain/product_model.dart';
import '../../../cart/cart_screen.dart';

class ServiceCategoryProductListItem extends StatefulWidget {
  static const double MAX_HEIGHT_PORTRAIT = 130;
  static const double MAX_HEIGHT_LANDSCAPE = 110;
  final ProductModel product;
  final String serviceId;
  final String categoryName;

  const ServiceCategoryProductListItem(
      this.serviceId, this.categoryName, this.product,
      {Key key})
      : super(key: key);

  @override
  ServiceCategoryProductListItemState createState() =>
      ServiceCategoryProductListItemState();
}

class ServiceCategoryProductListItemState
    extends State<ServiceCategoryProductListItem> {
  bool expanded = false;

  Widget _getImageWidget() {
    return FadeInImage.assetNetwork(
      fit: BoxFit.fill,
      placeholder: 'assets/images/placeholders/product_placeholder.jpg',
      image: widget.product.imageUrl,
    );
  }

  Widget _getPriceWidget(String serviceId, ThemeData theme) {
    return Text(_formatPrice(widget.product.price - widget.product.discount),
        style: theme.textTheme.titleMedium);
  }

  String _formatPrice(num n) {
    if (n == null) return null;
    return 'Rs ${n.ceil().toStringAsFixed(0)}/-';
  }

  Widget _getOldPriceWidget(String serviceId, ThemeData theme) {
    return CustomPaint(
      painter: _LinePainter(),
      child: Text(
        _formatPrice(widget.product.price),
        style:
            theme.textTheme.titleSmall.copyWith(fontWeight: FontWeight.normal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    return mediaQuery.orientation == Orientation.portrait
        ? _getPortraitLayout(
            context: context,
            theme: theme,
            mediaQuery: mediaQuery,
            serviceId: widget.serviceId,
          )
        : _getLandscapeLayout(
            context: context,
            theme: theme,
            mediaQuery: mediaQuery,
            serviceId: widget.serviceId,
          );
  }

  Widget _getRemoveButton(
      BuildContext context, String serviceId, ThemeData theme) {
    return IconButton(
      color: theme.primaryColor,
      icon: const Icon(
        Icons.remove_circle,
        size: 30,
      ),
      onPressed: () => _productRemoveCallback(context, serviceId),
    );
  }

  Widget _getAddButton(
      BuildContext context, String serviceId, ThemeData theme) {
    return IconButton(
      color: theme.primaryColor,
      icon: const Icon(
        Icons.add_circle,
        size: 30,
      ),
      onPressed: () => _productAddCallback(context),
    );
  }

  Widget _getQuantityWidget(ThemeData theme) {
    return Consumer<CartProvider>(
      builder: (ctx, cartData, child) => Text(
        cartData.getQuantity(widget.product.productId).toString(),
        style: theme.textTheme.titleLarge,
      ),
    );
  }

  Widget _getPortraitLayout(
      {@required String serviceId,
      @required MediaQueryData mediaQuery,
      @required BuildContext context,
      @required ThemeData theme}) {
    return Column(
      children: [
        SizedBox(
          height: ServiceCategoryProductListItem.MAX_HEIGHT_PORTRAIT,
          width: mediaQuery.size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: ServiceCategoryProductListItem.MAX_HEIGHT_PORTRAIT,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      child: _getImageWidget(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.product.productName,
                        style:
                            theme.textTheme.titleLarge.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Row(
                          children: <Widget>[
                            if (widget.product.discount != 0)
                              _getOldPriceWidget(serviceId, theme),
                            const SizedBox(width: 10),
                            _getPriceWidget(serviceId, theme),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              widget.product.descriptions.isNotEmpty
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.end,
                          children: <Widget>[
                            if (widget.product.descriptions.isNotEmpty)
                              TextButton(
                                child: Row(
                                  children: [
                                    const Text(
                                      "View Details",
                                    ),
                                    Icon(expanded
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    expanded = !expanded;
                                  });
                                },
                              ),
                            _getRemoveButton(context, serviceId, theme),
                            _getQuantityWidget(theme),
                            _getAddButton(context, serviceId, theme),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (expanded) ...[
          const SizedBox(
            height: 5,
          ),
          MySeparator(color: theme.primaryColor),
          const SizedBox(
            height: 5,
          ),
          Column(
            children: widget.product.descriptions
                .map(
                  (e) => Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      _showBullets(),
                      const SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _getLandscapeLayout(
      {@required String serviceId,
      @required MediaQueryData mediaQuery,
      @required BuildContext context,
      @required ThemeData theme}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            height: 17,
            alignment: Alignment.center,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(widget.product.productName,
                  style: theme.textTheme.titleLarge),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor, width: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              height: ServiceCategoryProductListItem.MAX_HEIGHT_LANDSCAPE,
              width: MediaQuery.of(context).size.width * 0.15,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  child: _getImageWidget(),
                ),
              ),
            ),
            Column(
              children: [
                if (widget.product.discount != 0)
                  _getOldPriceWidget(serviceId, theme),
                _getPriceWidget(serviceId, theme),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.product.descriptions.isNotEmpty)
              TextButton(
                child: const Row(
                  children: [
                    Text(
                      "View Details",
                    ),
                    Icon(Icons.info),
                  ],
                ),
                onPressed: () {
                  _showLandscapeDescription();
                },
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _getRemoveButton(context, serviceId, theme),
            _getQuantityWidget(theme),
            _getAddButton(context, serviceId, theme),
          ],
        ),
      ],
    );
  }

  void _showLandscapeDescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: widget.product.descriptions.map((e) => Text(e)).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _showBullets() {
    return Container(
      height: 5,
      width: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
    );
  }

  Future<void> _productRemoveCallback(
      BuildContext context, String serviceId) async {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    bool isDone = await cartData.removeItem(
      serviceId: serviceId,
      productId: widget.product.productId,
    );
    if (!isDone) {
      bool val = await _showGotoCheckoutPopup(context);
      if (val) {
        Navigator.of(context).pushNamed(CartScreen.routeName);
      }
    }
  }

  Future<bool> _showGotoCheckoutPopup(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blue, width: 2.0),
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Cannot remove'),
            content:
                const Text('Goto checkout page to remove customized orders?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  Future<void> _productAddCallback(BuildContext context) async {
    var cartData = Provider.of<CartProvider>(context, listen: false);
    var serviceData = Provider.of<ServiceProvider>(context, listen: false);
    cartData.addItem(
      serviceId: widget.serviceId,
      productId: widget.product.productId,
      item: CartModel(
        categoryName: widget.categoryName,
        serviceName: serviceData.getServiceName(widget.serviceId),
        price: (widget.product.price - widget.product.discount).ceil(),
        title: widget.product.productName,
        id: null,
        quantity: null,
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;
    canvas.drawLine(size.topRight(const Offset(0, 0)),
        size.bottomLeft(const Offset(0, 0)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({Key key, this.height = 2, this.color = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 2.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (5 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
