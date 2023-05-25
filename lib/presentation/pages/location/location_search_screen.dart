import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_webservice/places.dart' as placesapi;
import 'package:washry/application/locations.dart';
import 'package:washry/core/constants/constants.dart';
import '../../../presentation/pages/location/location_select_screen.dart';

class LocationSearchScreen extends StatefulWidget {
  static const String routeName = 'Location-Search-Screen';

  const LocationSearchScreen({Key key}) : super(key: key);

  @override
  LocationSearchScreenState createState() => LocationSearchScreenState();
}

class LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<placesapi.Prediction> _suggestions = [];
  Timer _requestThrottle;
  bool loading = false;
  bool isInitial = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchChanged);
    Future.delayed(
      Duration.zero,
      () {
        isInitial = ModalRoute.of(context).settings.arguments ?? false;
      },
    );
  }

  Future<List<placesapi.Prediction>> getSuggestions(String value) async {
    var places = placesapi.GoogleMapsPlaces(apiKey: "");
    var autoCompleteData = await places.autocomplete(value);
    places.dispose();
    return autoCompleteData.predictions;
  }

  void _searchChanged() {
    setState(() {
      loading = true;
    });
    if (_requestThrottle.isActive) {
      _requestThrottle.cancel();
    }
    _requestThrottle = _searchTimer;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.removeListener(_searchChanged);
    _searchController.dispose();
  }

  Future<void> _suggestionItemOnTapCallback(placesapi.Prediction item) async {
    setState(() {
      loading = true;
    });
    var places = placesapi.GoogleMapsPlaces(apiKey: Constants.apiKey);
    var data = await places.getDetailsByPlaceId(item.placeId);
    double lat = data.result.geometry.location.lat;
    double lng = data.result.geometry.location.lng;

    setState(() {
      loading = false;
    });
    
    if (context.mounted) return;
    var didUserSelectLocationOnMap = await Navigator.pushNamed(
        context, LocationSelectScreen.routeName,
        arguments: LatLng(lat, lng));

    _searchController.clear();
    _suggestions.clear();

    if (didUserSelectLocationOnMap) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _gpsIconOnTapCallback() async {
    setState(() {
      loading = true;
    });
    var locationData = Provider.of<LocationProvider>(context, listen: false);
    var data = await locationData.getCurrentLocation();
    //If null means location permission denied or service not enabled
    setState(() {
      loading = false;
    });
    var didUserSelectLocationOnMap = await Navigator.of(context).pushNamed(
        LocationSelectScreen.routeName,
        arguments: LatLng(data.latitude, data.longitude));
    setState(() {
      loading = false;
    });
    if (didUserSelectLocationOnMap) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _backPressedCallback,
        child: Scaffold(
          appBar: _appbar,
          body: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    ..._suggestionList,
                    _suggestionList.isNotEmpty
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              const Divider(
                                thickness: 2.0,
                                color: Colors.black,
                              ),
                              Container(
                                width: 30,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                                child: const Text("Or"),
                              )
                            ],
                          )
                        : const SizedBox(
                            height: 2.0,
                          ),
                    _gpsLocationSelectWidget
                  ],
                ),
        ),
      ),
    );
  }

  AppBar get _appbar => AppBar(
        leadingWidth: 40,
        title: TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          autofocus: true,
          decoration: const InputDecoration(
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            hintText: 'Enter Building / Society / Landmark / Locality',
            hintStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          controller: _searchController,
        ),
      );

  List<Widget> get _suggestionList => _suggestions
      .map(
        (item) => ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          minLeadingWidth: 10,
          title: Text(item.description),
          onTap: () => _suggestionItemOnTapCallback(item),
          visualDensity: VisualDensity.compact,
          minVerticalPadding: 1,
          subtitle: const Divider(
            thickness: 0.5,
            color: Colors.black,
          ),
        ),
      )
      .toList();

  Widget get _gpsLocationSelectWidget => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              style: BorderStyle.solid,
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          onTap: () => _gpsIconOnTapCallback(),
          leading: Icon(
            Icons.gps_fixed,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            'Use Current Location',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
            ),
          ),
        ),
      );

  Timer get _searchTimer => Timer(const Duration(milliseconds: 500), () {
        setState(() {
          loading = false;
        });
        if (_searchController.text.isNotEmpty) {
          getSuggestions(_searchController.text).then((value) {
            if (!mounted) return;
            setState(() {
              _suggestions = value;
            });
          });
        }
      });

  Future<bool> _backPressedCallback() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Colors.blue,
            width: 3.0,
          ),
        ),
        content: isInitial
            ? const Text('Do you want to exit the app?')
            : const Text('Do you really want to go back?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
