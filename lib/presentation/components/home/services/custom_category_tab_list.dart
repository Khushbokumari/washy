import 'package:flutter/material.dart';

import '../../../../domain/category_model.dart';
import 'custom_category_tab.dart';

class CategoryTabList extends StatelessWidget {
  final Category category;
  final String serviceId;

  const CategoryTabList(this.serviceId, this.category, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait
        ? ListView.separated(
            separatorBuilder: (ctx, index) => Divider(
              color: Theme.of(context).primaryColor,
              thickness: 0.2,
            ),
            itemCount: category.categoryProducts.length,
            itemBuilder: (ctx, index) => CategoryTabItem(
              serviceId,
              category.categoryName,
              category.categoryProducts[index],
            ),
          )
        : GridView.builder(
            itemCount: category.categoryProducts.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 1 / 1,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 0.2,
                ),
              ),
              child: CategoryTabItem(
                serviceId,
                category.categoryName,
                category.categoryProducts[index],
              ),
            ),
          );
  }
}
