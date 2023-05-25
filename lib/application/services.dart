import '../domain/category_model.dart';
import '../domain/service_model.dart';

class ServiceProvider {
  final List<ServiceModel> _services = [];
  ServiceProvider(this.locationId, this._services);

  String locationId;
  List<ServiceModel> get services {
    return [..._services];
  }

  List<ServiceModel> getOneTimeService() {
    List<ServiceModel> oneTimeServices = [];
    for (int i = 0; i < services.length; i++) {
      if (services[i] is MultiServiceModel) {
        var serviceNode = services[i] as MultiServiceModel;
        if (serviceNode.isOneTimeService) oneTimeServices.add(serviceNode);
      } else if (services[i] is SingleServiceModel) {
        //tank
        var service = services[i] as SingleServiceModel;
        if (service.isOneTimeService) oneTimeServices.add(service);
      }
    }
    return oneTimeServices;
  }

  List<ServiceModel> getTwoTimeService() {
    List<ServiceModel> twoTimeServices = [];

    for (int i = 0; i < services.length; i++) {
      if (services[i] is MultiServiceModel) {
        var serviceNode = services[i] as MultiServiceModel;
        if (!serviceNode.isOneTimeService) twoTimeServices.add(serviceNode);
      } else if (services[i] is SingleServiceModel) {
        //tank
        var service = services[i] as SingleServiceModel;
        if (!service.isOneTimeService) twoTimeServices.add(service);
      }
    }
    return twoTimeServices;
  }

  String getServiceName(String serviceId) {
    for (var i = 0; i < _services.length; ++i) {
      var name = _services[i].getServiceName(serviceId);
      if (name != null) {
        return name;
      }
    }
    return null;
  }

  ServiceModel getParentInfo(String serviceId) {
    ServiceModel node;
    SingleServiceModel t;
    for (int i = 0; i < _services.length; i++) {
      if (_services[i] is MultiServiceModel) {
        MultiServiceModel tempNode = _services[i];
        for (int j = 0; j < tempNode.children.length; j++) {
          if (tempNode.children[j].serviceId == serviceId) {
            node = tempNode;
          }
        }
      } else {
        t = _services[i];
        break;
      }
    }
    if (node == null) return t;
    return node;
  }

  SingleServiceModel getserviceInfoforproduct(String productId) {
    SingleServiceModel node;
    SingleServiceModel t;
    for (int i = 0; i < _services.length; i++) {
      if (_services[i] is MultiServiceModel) {
        MultiServiceModel tempNode = _services[i];
        for (int j = 0; j < tempNode.children.length; j++) {
          for (int k = 0; k < tempNode.children[j].categories.length; k++) {
            for (var element
                in tempNode.children[j].categories[k].categoryProducts) {
              if (element.productId == productId) {
                node = tempNode.children[j];
              }
            }
          }
        }
      } else {
        t = _services[i];
        break;
      }
    }

    if (node == null) return t;
    return node;
  }

  String getProductName(String productId) {
    String parentname = "amitTiwari";
    for (int i = 0; i < _services.length; i++) {
      if (_services[i] is MultiServiceModel) {
        MultiServiceModel tempNode = _services[i];
        for (int j = 0; j < tempNode.children.length; j++) {
          for (int k = 0; k < tempNode.children[j].categories.length; k++) {
            for (var element
                in tempNode.children[j].categories[k].categoryProducts) {
              if (element.productId == productId) {
                parentname = element.productName;
              }
            }
          }
        }
      } else if (_services[i] is SingleServiceModel) {
        SingleServiceModel tempNode = _services[i];
        for (int k = 0; k < tempNode.categories.length; k++) {
          for (var element in tempNode.categories[k].categoryProducts) {
            if (element.productId == productId) {
              parentname = element.productName;
            }
          }
        }
      }
    }
    return parentname;
  }

  String getParentName(String parentId) {
    for (var i = 0; i < _services.length; ++i) {
      if (_services[i] is MultiServiceModel) {
        MultiServiceModel node = _services[i] as MultiServiceModel;
        if (node.parentId == parentId) {
          return node.parentName;
        }
      } else if (_services[i] is SingleServiceModel) {
        SingleServiceModel node = _services[i] as SingleServiceModel;
        if (node.serviceId == parentId) {
          return node.serviceName;
        }
      }
    }
    return null;
  }

  num getParentMinAmount(String parentId) {
    num minAmount;
    for (var element in _services) {
      if (element is MultiServiceModel) {
        if (element.parentId == parentId) {
          minAmount = element.minAmount;
        }
      } else if (element is SingleServiceModel) {
        if (element.serviceId == parentId) minAmount = element.minAmount;
      }
    }
    return minAmount;
  }

  Map<String, bool> getServiceNature() {
    Map<String, bool> servicesNature = {};
    for (var element in _services) {
      if (element is MultiServiceModel) {
        servicesNature[element.parentId] = element.isOneTimeService;
      } else if (element is SingleServiceModel) {
        servicesNature[element.serviceId] = element.isOneTimeService;
      }
    }
    return servicesNature;
  }

  List<Category> getCategories(String serviceId) {
    for (var i = 0; i < _services.length; ++i) {
      var categories = _services[i].getCategories(serviceId);
      if (categories != null) {
        return categories;
      }
    }
    return null;
  }

  num getMinAmount(String serviceId) {
    for (var i = 0; i < _services.length; ++i) {
      var minAmount = _services[i].getMinAmount(serviceId);
      if (minAmount != null) {
        return minAmount;
      }
    }
    return null;
  }

  int getMinServiceTime(String serviceId) {
    for (var i = 0; i < _services.length; ++i) {
      var time = _services[i].getMinServiceTime(serviceId);
      if (time != null) {
        return time;
      }
    }
    return null;
  }
}
