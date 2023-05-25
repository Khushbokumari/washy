import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import "package:google_maps_webservice/geocoding.dart" as gioloc;
import 'package:washry/application/locations.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:washry/core/constants/constants.dart';

class LocationSelectScreen extends StatefulWidget {
  static const String routeName = 'Location-Select-Screen';

  const LocationSelectScreen({Key key}) : super(key: key);

  @override
  LocationSelectScreenState createState() => LocationSelectScreenState();
}

class LocationSelectScreenState extends State<LocationSelectScreen> {
  LatLng latLng;
  bool loading = true;
  bool init = true;
  Timer _throttle;
  List<String> addressComponents;
  GoogleMapController _controller;

  Widget get _gpsIconWidget => Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          tooltip: 'Use GPS',
          icon: const Icon(
            Icons.gps_fixed,
            size: 25,
          ),
          onPressed: () async {
            var locationData =
                Provider.of<LocationProvider>(context, listen: false);
            _moveToLocation(await locationData.getCurrentLocation());
          },
        ),
      );

  String get _formattedAddress =>
      addressComponents.fold('', (prev, curr) => '$prev$curr, ');

  Widget get _confirmButtonWidget {
    return GestureDetector(
      onTap: loading ? null : _confirmButtonCallback,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.blue,
          ),
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'CONFIRM LOCATION',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmButtonCallback() async {
    var locationData = Provider.of<LocationProvider>(context, listen: false);
    await locationData.saveCurrentLocation(latLng, addressComponents[2]);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      latLng = ModalRoute.of(context).settings.arguments;
      init = false;
    }
  }

  void _mapMoved() {
    if (_throttle.isActive) _throttle.cancel();
    _throttle = Timer(const Duration(seconds: 1), () {
      findAddress(latLng).then((components) {
        setState(() {
          addressComponents = components;
          loading = false;
        });
      });
    });
  }

  Future<List<String>> findAddress(LatLng location) async {
    var geoCoding = gioloc.GoogleMapsGeocoding(apiKey: Constants.apiKey);
    var response = await geoCoding.searchByLocation(
        gioloc.Location(location.latitude, location.longitude));
    geoCoding.dispose();
    return response.results[0].addressComponents
        .map((item) => item.shortName)
        .toList();
  }

  Widget get _googleMap {
    return GoogleMap(
      compassEnabled: true,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: true,
      onMapCreated: (controller) {
        _controller = controller;
        _mapMoved();
      },
      initialCameraPosition: CameraPosition(
        target: latLng,
        zoom: 18,
      ),
      onCameraMove: (position) {
        setState(() {
          loading = true;
          latLng = LatLng(position.target.latitude, position.target.longitude);
        });
        _mapMoved();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    // double mapHeightFactor =
    //     mediaQuery.orientation == Orientation.portrait ? 0.65 : 0.55;
    double mapHeightFactor =
        mediaQuery.orientation == Orientation.portrait ? 0.75 : 0.55;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Confirm Your Location"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: mediaQuery.size.height * mapHeightFactor,
                    child: _googleMap,
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      height: 50,
                      child: Image.asset(
                        "assets/images/marker.png",
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Center(
                    child: SpinKitPulse(
                      color: Theme.of(context).primaryColor,
                      size: 100.0,
                    ),
                  ),
                  loading
                      ? Container()
                      : Positioned(
                          top: mediaQuery.size.height / 5.2,
                          child: Column(
                            children: [
                              Container(
                                width: mediaQuery.size.width - 120,
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Selected Location".toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _formattedAddress,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        maxLines: 3,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  loading
                      ? Container()
                      : Positioned(
                          right: mediaQuery.size.width / 3.5,
                          bottom: mapHeightFactor + 20,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Move the pin to adjust",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                  Positioned(
                    top: mediaQuery.size.height * mapHeightFactor - 60,
                    left: mediaQuery.size.width - 65,
                    child: _gpsIconWidget,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _confirmButtonWidget,
            ],
          ),
        ),
      ),
    );
  }

  void _moveToLocation(LatLng location) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 19,
        ),
      ),
    );
    setState(() {
      latLng = LatLng(location.latitude, location.longitude);
    });
  }
}
