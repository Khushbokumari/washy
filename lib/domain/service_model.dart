import 'category_model.dart';

class ServiceModel {
  ServiceModel._();

  //Segregation
  factory ServiceModel.fromMappedObject(
      String id, Map<String, dynamic> map, String parentId) {
    if (map.containsKey('categories') && !map.containsKey('isSubService')) {
      // Assume As a SingleService
      return SingleServiceModel.fromMappedObject(id, map, parentId);
    } else {
      // Assume As a MultiService
      return MultiServiceModel.fromMappedObject(id, map, parentId);
    }
  }

  String? getServiceName(String serviceId) {
    if (this is SingleServiceModel) {
      var service = this as SingleServiceModel;
      return service.serviceId == serviceId ? service.serviceName : null;
    } else {
      var node = this as MultiServiceModel;
      for (var i = 0; i < node.children.length; ++i) {
        var name = node.children[i].getServiceName(serviceId);
        if (name != null) {
          return name;
        }
      }
      return null;
    }
  }

  num? getMinAmount(String serviceId) {
    if (this is SingleServiceModel) {
      var service = this as SingleServiceModel;
      return service.serviceId == serviceId ? service.minAmount : null;
    } else {
      var node = this as MultiServiceModel;
      for (var i = 0; i < node.children.length; ++i) {
        var amount = node.children[i].getMinAmount(serviceId);
        if (amount != null) {
          return amount;
        }
      }
      return null;
    }
  }

  int? getMinServiceTime(String serviceId) {
    if (this is SingleServiceModel) {
      var service = this as SingleServiceModel;
      return service.serviceId == serviceId ? service.minTime : null;
    } else {
      var node = this as MultiServiceModel;
      for (var i = 0; i < node.children.length; ++i) {
        var time = node.children[i].getMinServiceTime(serviceId);
        if (time != null) {
          return time;
        }
      }
      return null;
    }
  }

  List<Category>? getCategories(String serviceId) {
    if (this is SingleServiceModel) {
      var service = this as SingleServiceModel;
      return service.serviceId == serviceId ? service.categories : null;
    } else {
      var node = this as MultiServiceModel;
      for (var i = 0; i < node.children.length; ++i) {
        var categories = node.children[i].getCategories(serviceId);
        if (categories != null) {
          return categories;
        }
      }
      return null;
    }
  }
}

class MultiServiceModel extends ServiceModel {
  String parentName;
  String imageUrl;
  List<String> banners = [];
  String parentId;
  bool isBannerVideo;
  List<SingleServiceModel> children = [];
  bool isActive;
  List<int> priceList = [];
  num minAmount;
  String message;
  bool isOneTimeService;

  MultiServiceModel.fromMappedObject(
      String id, Map<String, dynamic> map, String mainId)
      : super._() {
    parentId = id;
    imageUrl = map['imageUrl'];
    parentName = map['alternateName'] ?? map['name'];
    isBannerVideo = map['isBannerVideo'] ?? false;
    final status = map['status'] as Map<String, dynamic>;
    isActive = status['isActive'];
    message = status['message'];
    isOneTimeService = map['isOneTimeService'];
    for (var i in map['bannerList']) {
      banners.add(i as String);
    }
    map['children'].forEach(
      (key, value) =>
          children.add(ServiceModel.fromMappedObject(key, value, id)),
    );
    minAmount = map['minAmount'];
  }
}

class SingleServiceModel extends ServiceModel {
  String serviceName;
  String serviceId;
  String imageUrl;
  List<Category> categories = [];
  num minAmount;
  Map<String, num> price = {};
  int minTime;
  bool isActive;
  String message;
  bool isOneTimeService;
  String parentId;

  SingleServiceModel.fromMappedObject(
      String id, Map<String, dynamic> map, String parentId)
      : super._() {
    serviceId = id;
    parentId = parentId;
    serviceName = map['name'];
    minAmount = map['minAmount'];
    minTime = map['minTime'];
    imageUrl = map['imageUrl'];
    isOneTimeService = map['isOneTimeService'];
    final status = map['status'] as Map<String, dynamic>;
    isActive = status['isActive'];
    message = status['message'];
    var categoryData = map['categories'] as Map<String, dynamic>;
    categoryData.forEach(
        (id, data) => categories.add(Category.fromMappedObject(id, data)));
    categories.sort((b, a) => a.categoryPriority.compareTo(b.categoryPriority));
  }
}

class ServicePrice {
  final String parentId;
  final Map price;
  final String serviceId;
  ServicePrice({this.parentId, this.serviceId, this.price});
}
