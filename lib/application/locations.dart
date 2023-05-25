import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/utils/location_math.dart';
import '../domain/location_model.dart';
import '../core/network/url.dart';

class SavedLocation {
  LatLng latLng;
  String locality;

  SavedLocation(this.latLng, this.locality);
}

class LocationProvider with ChangeNotifier {
  List<LocationModel> _locations = [];
  late SavedLocation _savedLocation;
  late LocationModel currentOperationLocation;

  SavedLocation get savedLocation =>
      SavedLocation(_savedLocation.latLng, _savedLocation.locality);

  void _clearPreviousData() {
    _locations = [];
    currentOperationLocation = null;
  }

  Future<void> getLocationsFromServer() async {
    _clearPreviousData();
    const url = "${URL.LOCATION_DATABASE_URL}.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    responseData.forEach((locationId, data) {
      final parsedLocationItem =
          LocationModel.fromMappedObject(locationId, data);
      _locations.add(parsedLocationItem);
      _tryUpdateCurrentOperationLocation(parsedLocationItem);
    });
    notifyListeners();
  }

  Future<bool> hasSavedLocation() async {
    var sharedPreferenceInstance = await SharedPreferences.getInstance();
    if (sharedPreferenceInstance.containsKey('savedLocation')) {
      _setSavedLocation(sharedPreferenceInstance);
      return true;
    } else {
      return false;
    }
  }

  void _setSavedLocation(SharedPreferences sharedPreferenceInstance) {
    var loadedData =
        jsonDecode(sharedPreferenceInstance.getString('savedLocation'))
            as Map<String, dynamic>;
    _savedLocation = SavedLocation(
      LatLng(
        loadedData['latitude'],
        loadedData['longitude'],
      ),
      loadedData['locality'],
    );
  }

  Future<void> saveCurrentLocation(LatLng item, String locality) async {
    _savedLocation = SavedLocation(item, locality);
    final pref = await SharedPreferences.getInstance();
    pref.setString(
      'savedLocation',
      jsonEncode(
        {
          'latitude': item.latitude,
          'longitude': item.longitude,
          'locality': locality,
        },
      ),
    );
  }

  Future<LatLng> getCurrentLocation() async {
    Location location = Location();
    bool isLocationEnabled = await location.serviceEnabled();
    if (!isLocationEnabled) {
      bool retry = await location.requestService();
      if (!retry) return null;
    }
    if (await location.hasPermission() != PermissionStatus.granted) {
      if (await location.hasPermission() != PermissionStatus.deniedForever) {
        if (await location.requestPermission() != PermissionStatus.granted) {
          return null;
        }
      } else {
        return null;
      }
    }
    LocationData locationData = await location.getLocation();
    return LatLng(
      locationData.latitude,
      locationData.longitude,
    );
  }

  void _tryUpdateCurrentOperationLocation(LocationModel loc) {
    if (LocationMath.isInsideRadius(loc, _savedLocation.latLng)) {
      if (currentOperationLocation == null) {
        currentOperationLocation = loc;
      } else {
        var currentDistance = LocationMath.distanceBetween(
            LatLng(loc.latitude, loc.longitude), _savedLocation.latLng);
        var previousShortDistance = LocationMath.distanceBetween(
            LatLng(currentOperationLocation.latitude,
                currentOperationLocation.longitude),
            savedLocation.latLng);
        if (currentDistance < previousShortDistance) {
          currentOperationLocation = loc;
        }
      }
    }
  }
}
