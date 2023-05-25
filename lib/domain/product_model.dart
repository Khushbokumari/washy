class ProductModel {
  String productId;
  String productName;
  int positionalPriority;
  num discount;
  num price;
  String imageUrl;
  List<String> descriptions = [];

  ProductModel.fromMappedObject(String id, Map<String, dynamic> data) {
    productId = id;
    productName = data['name'];
    imageUrl = data['image_url'];
    discount = data['discount'];
    positionalPriority = data['positionalPriority'];
    price = data['price'];
    if (data.containsKey('description')) {
      final desc = data['description'] as Map<String, dynamic>;
      desc.forEach((key, value) {
        descriptions.add(value);
      });
    }
  }
}
