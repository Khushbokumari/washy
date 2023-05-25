import 'service_model.dart';
import 'slot_model.dart';
import 'promocode_model.dart';

// class LocationModel {
//   String locationId;
//   List<String> banners = [];
//   num latitude, longitude;
//   num radius;
//   List<PromoCodeModel> promos = [];
//   List<ServiceModel> services = [];
//   List<SlotsModel> deliverySlots = [];
//   Map<int, int> deliveryCharges = {};
//   Map<String, List<PromoCodeModel>> promosMap = {};
//   Map<String, List<SlotsModel>> slotsDelivery = {};
//   Map<String, List<SlotsModel>> delDelivery = {};
//   Map<String, Map<int, int>> priceDelivery = {};
//
//   //New
//   Map<String, List<SlotsModel>> newSlots = {};
//   Map<String, List<SlotsModel>> newPickupSlots = {};
//   Map<String, List<SlotsModel>> newDeliverySlots = {};
//   //New
//
//   LocationModel.fromMappedObject(
//       String locationId, Map<String, dynamic> locationData) {
//     locationId = locationId;
//
//     var bannersData = locationData['banners'] as Map<String, dynamic>;
//     bannersData.forEach((bannerId, bannerUrl) => banners.add(bannerUrl));
//
//     latitude = locationData['lat'];
//     longitude = locationData['long'];
//
//     locationData['promos'].forEach((id, map) {
//       List<PromoCodeModel> list = [];
//       map.forEach((i, dataMap) {
//         list.add(PromoCodeModel.fromMappedObject(id, dataMap));
//       });
//       promosMap[id] = list;
//     });
//
//     radius = locationData['radius'];
//
//     var serviceData = locationData['services'] as Map<String, dynamic>;
//     serviceData.forEach((serviceId, map) {
//       services.add(ServiceModel.fromMappedObject(serviceId, map, ''));
//     });
//
//     locationData['services'].forEach((serviceId, item) {
//       var deliveryData = item['delivery'];
//       List<SlotsModel> list = [];
//       deliveryData['slots'].forEach((slotsId, item) {
//         list.add(SlotsModel.fromMappedObject(slotsId, item));
//       });
//       slotsDelivery[serviceId] = list;
//
//       Map<int, int> price = {};
//       deliveryData['price'].forEach((id, item) {
//         price[int.parse(id)] = item;
//       });
//       priceDelivery[serviceId] = price;
//
//       if (item['isOneTimeService'] == false) {
//         List<SlotsModel> slots = [];
//         deliveryData['del'].forEach((deliveryId, item) {
//           slots.add(SlotsModel.fromMappedObject(serviceId, item));
//         });
//         delDelivery[serviceId] = slots;
//       }
//     });
//
//     //OneTimeSlots
//     locationData['slots']['oneTimeServiceSlots'].forEach((serviceId, data) {
//       List<SlotsModel> oneTimeSlots = [];
//       data['slots'].forEach((id, item) {
//         oneTimeSlots.add(SlotsModel.fromMappedObject(serviceId, item));
//       });
//       newSlots[serviceId] = oneTimeSlots;
//     });
//
//     // TwoTimeSlots
//     locationData['slots']['twoTimeServiceSlots'].forEach((serviceId, data) {
//       List<SlotsModel> twoTimeDeliverySlots = [];
//       data['deliverySlots'].forEach((id, item) {
//         twoTimeDeliverySlots
//             .add(SlotsModel.fromMappedObject(serviceId, item));
//       });
//       newDeliverySlots[serviceId] = twoTimeDeliverySlots;
//
//       List<SlotsModel> twoTimePickupSlots = [];
//       data['pickupSlots'].forEach((id, item) {
//         twoTimePickupSlots.add(SlotsModel.fromMappedObject(serviceId, item));
//       });
//       newPickupSlots[serviceId] = twoTimePickupSlots;
//     });
//   }
// }
class LocationModel {
  String locationId;
  List<String> banners = [];
  num latitude, longitude;
  num radius;
  List<PromoCodeModel> promos = [];
  List<ServiceModel> services = [];
  List<SlotsModel> deliverySlots = [];
  Map<int, int> deliveryCharges = {};
  Map<String, List<PromoCodeModel>> promosMap = {};
  Map<String, List<SlotsModel>> slotsDelivery = {};
  Map<String, List<SlotsModel>> delDelivery = {};
  Map<String, Map<int, int>> priceDelivery = {};

  //New
  Map<String, List<SlotsModel>> newSlots = {};
  Map<String, List<SlotsModel>> newPickupSlots = {};
  Map<String, List<SlotsModel>> newDeliverySlots = {};
  //New

  LocationModel.fromMappedObject(
      String locationId, Map<String, dynamic> locationData) {
    locationId = locationId;

    var bannersData = locationData['banners'] as Map<String, dynamic>;
    bannersData.forEach((bannerId, bannerUrl) => banners.add(bannerUrl));

    latitude = locationData['lat'];
    longitude = locationData['long'];

    locationData['promos'].forEach((id, map) {
      List<PromoCodeModel> list = [];
      map.forEach((i, dataMap) {
        list.add(PromoCodeModel.fromMappedObject(id, dataMap));
      });
      promosMap[id] = list;
    });

    radius = locationData['radius'];

    var serviceData = locationData['services'] as Map<String, dynamic>;
    serviceData.forEach((serviceId, map) {
      services.add(ServiceModel.fromMappedObject(serviceId, map, ''));
    });

    locationData['services'].forEach((serviceId, item) {
      var deliveryData = item['delivery'];
      List<SlotsModel> list = [];
      deliveryData['slots'].forEach((slotsId, item) {
        list.add(SlotsModel.fromMappedObject(slotsId, item));
      });
      slotsDelivery[serviceId] = list;

      Map<int, int> price = {};
      deliveryData['price'].forEach((id, item) {
        price[int.parse(id)] = item;
      });
      priceDelivery[serviceId] = price;

      if (item['isOneTimeService'] == false) {
        List<SlotsModel> slots = [];
        deliveryData['del'].forEach((deliveryId, item) {
          slots.add(SlotsModel.fromMappedObject(serviceId, item));
        });
        delDelivery[serviceId] = slots;
      }
    });

    //OneTimeSlots
    locationData['slots']['oneTimeServiceSlots'].forEach((serviceId, data) {
      List<SlotsModel> oneTimeSlots = [];
      data['slots'].forEach((id, item) {
        oneTimeSlots.add(SlotsModel.fromMappedObject(serviceId, item));
      });
      newSlots[serviceId] = oneTimeSlots;
    });

    // TwoTimeSlots
    locationData['slots']['twoTimeServiceSlots'].forEach((serviceId, data) {
      List<SlotsModel> twoTimeDeliverySlots = [];
      data['deliverySlots'].forEach((id, item) {
        twoTimeDeliverySlots
            .add(SlotsModel.fromMappedObject(serviceId, item));
      });
      newDeliverySlots[serviceId] = twoTimeDeliverySlots;

      List<SlotsModel> twoTimePickupSlots = [];
      data['pickupSlots'].forEach((id, item) {
        twoTimePickupSlots.add(SlotsModel.fromMappedObject(serviceId, item));
      });
      newPickupSlots[serviceId] = twoTimePickupSlots;
    });
  }
}