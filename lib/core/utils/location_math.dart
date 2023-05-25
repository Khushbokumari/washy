import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/location_model.dart';

// class LocationMath {
//   static bool isInsideRadius(LocationModel location, LatLng child) {
//     return _distance(child.latitude, child.longitude, location.latitude,
//             location.longitude) <
//         location.radius;
//   }
//
//   static double _distance(double lat1, double lon1, double lat2, double lon2) {
//     double theta = lon1 - lon2;
//     double dist = sin(_deg2rad(lat1)) * sin(_deg2rad(lat2)) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * cos(_deg2rad(theta));
//     dist = acos(dist);
//     dist = _rad2deg(dist);
//     return dist = dist * 60 * 1.1515;
//   }
//
//   static double _deg2rad(double deg) {
//     return (deg * pi / 180.0);
//   }
//
//   static double _rad2deg(double rad) {
//     return (rad * 180.0 / pi);
//   }
//
//   static double distanceBetween(LatLng location1, LatLng location2) {
//     return _distance(location1.latitude, location1.longitude,
//         location2.latitude, location2.longitude);
//   }
// }
class LocationMath {
  static bool isInsideRadius(LocationModel location, LatLng child) {
    if (child == null) {
      return false;
    }
    return _distance(child.latitude.toDouble(), child.longitude, location.latitude,
        location.longitude) <
        location.radius;
  }

  static double _distance(double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = sin(_deg2rad(lat1)) * sin(_deg2rad(lat2)) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * cos(_deg2rad(theta));
    dist = acos(dist);
    dist = _rad2deg(dist);
    return dist * 60 * 1.1515;
  }

  static double _deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  static double _rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  static double distanceBetween(LatLng location1, LatLng location2) {
    return _distance(location1.latitude, location1.longitude,
        location2.latitude, location2.longitude);
  }
}