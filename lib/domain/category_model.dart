import 'product_model.dart';

class Category {
  String categoryId;
  String categoryName;
  int categoryPriority;
  List<ProductModel> categoryProducts = [];

  Category.fromMappedObject(String id, Map<String, dynamic> data) {
    categoryId = id;
    categoryName = data['name'];
    categoryPriority = data['positionalPriority'];
    final products = data['products'] as Map<String, dynamic>;
    products.forEach(
        (id, data) => categoryProducts.add(ProductModel.fromMappedObject(id, data)));
    categoryProducts.sort((a, b) => a.productName.compareTo(b.productName));
    categoryProducts
        .sort((b, a) => a.positionalPriority.compareTo(b.positionalPriority));
  }
}
