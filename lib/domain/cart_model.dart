class CartModel {
  String id;
  String serviceName;
  String title;
  num price;
  String categoryName;
  int quantity;

  CartModel({
    required this.id,
    required this.title,
    required this.serviceName,
    required this.price,
    required this.categoryName,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'serviceName': serviceName,
      'price': price,
      'categoryName': categoryName,
      'quantity': quantity,
    };
  }

  CartModel.fromMappedObject(Map<String, dynamic> item) {
    quantity = item['quantity'];
    price = item['price'];
    title = item['title'];
    categoryName = item['categoryName'];
    serviceName = item['serviceName'];
    id = item['id'];
  }
}
