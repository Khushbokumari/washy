import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:washry/domain/address_model.dart';
import 'package:washry/application/address.dart';
import 'package:washry/application/locations.dart';

class AddAddressScreen extends StatefulWidget {
  static const routeName = "Add-Address-Screen";

  const AddAddressScreen({Key key}) : super(key: key);

  @override
  AddAddressScreenState createState() => AddAddressScreenState();
}

class AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController _controller;
  LatLng _latLng;
  AddressModel _addressItem;
  final GlobalKey<FormState> _key = GlobalKey();
  bool init = true;
  bool loading = false;
  bool isConfirm = false;

  final _landmarkFocusNode = FocusNode();
  final _addressTextFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _contactFocusNode = FocusNode();
  final _contactController = TextEditingController();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _landmarkController = TextEditingController(text: "Near By ");
  final _addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      init = false;
      final id = ModalRoute.of(context).settings.arguments;
      if (id != null) {
        final address = Provider.of<AddressProvider>(context, listen: false)
            .addresses
            .firstWhere((item) => item.id == id);
        _addressController.text = address.addressText;
        _titleController.text = address.title;
        _nameController.text = address.contactName;
        _contactController.text = address.contactNumber;
        _landmarkController.text = address.landmark;
        _latLng = LatLng(address.lat, address.lng);
      } else {
        _latLng = Provider.of<LocationProvider>(context, listen: false)
            .savedLocation
            .latLng;
      }
    }
  }

  Widget get _nameFormField => TextFormField(
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Name cannot be empty';
          } else {
            return null;
          }
        },
        controller: _nameController,
        enableSuggestions: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.account_box,
            color: Theme.of(context).primaryColor,
          ),
          hintText: "Customer Name".toUpperCase(),
          contentPadding: const EdgeInsets.only(top: 15),
          hintStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_contactFocusNode),
        textInputAction: TextInputAction.next,
      );

  Widget get _titleFormField => TextFormField(
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Title cannot be empty';
          } else {
            return null;
          }
        },
        focusNode: _titleFocusNode,
        controller: _titleController,
        enableSuggestions: true,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.save,
              color: Theme.of(context).primaryColor,
            ),
            contentPadding: const EdgeInsets.only(top: 15),
            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
            hintText: 'Home / Office / Others etc'.toUpperCase()),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_addressTextFocusNode),
        textInputAction: TextInputAction.next,
      );

  Widget get _addressTextFormField => TextFormField(
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Address cannot be empty';
          } else {
            return null;
          }
        },
        controller: _addressController,
        focusNode: _addressTextFocusNode,
        enableSuggestions: true,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.home,
              color: Theme.of(context).primaryColor,
            ),
            contentPadding: const EdgeInsets.only(top: 15),
            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
            hintText: "House No, FLAT, FLOOR, BUILDING NAME".toUpperCase()),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_landmarkFocusNode),
        textInputAction: TextInputAction.next,
      );

  Widget get _landmarkFormField => TextFormField(
        validator: (value) {
          if (value.trim().isEmpty) {
            return 'Landmark cannot be empty';
          } else {
            return null;
          }
        },
        controller: _landmarkController,
        focusNode: _landmarkFocusNode,
        enableSuggestions: true,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.near_me,
              color: Theme.of(context).primaryColor,
            ),
            contentPadding: const EdgeInsets.only(top: 15),
            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
            hintText: "Landmark".toUpperCase()),
        textInputAction: TextInputAction.done,
      );

  String _contactValidator(value) {
    if (value.trim().isEmpty) return 'Contact cannot be empty';
    if (value.trim().length != 10) return 'Number can only be of length 10';
    try {
      num.parse(value);
      return null;
    } catch (e) {
      return 'Enter numeric value';
    }
  }

  Widget get _contactFormField => TextFormField(
        validator: _contactValidator,
        focusNode: _contactFocusNode,
        enableSuggestions: true,
        maxLength: 10,
        controller: _contactController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.call,
            color: Theme.of(context).primaryColor,
          ),
          hintText: 'Contact Number'.toUpperCase(),
          contentPadding: const EdgeInsets.only(top: 15),
          hintStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(_titleFocusNode),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      );

  @override
  void initState() {
    super.initState();
    _initElements();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const double mapHeightFactorAfterConfirm = 0.38;
    double mapHeightFactorBeforeConfirm =
        mediaQuery.orientation == Orientation.portrait ? 0.75 : 0.55;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Address'),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isConfirm
                ? SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: mediaQuery.size.height *
                                  mapHeightFactorAfterConfirm,
                              child: AbsorbPointer(
                                absorbing: isConfirm ? true : false,
                                child: _googleMap,
                              ),
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
                            Positioned(
                              top: mediaQuery.size.height *
                                      mapHeightFactorAfterConfirm -
                                  55,
                              right: 5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 5.0, backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(1.0)),
                                onPressed: () {
                                  setState(() {
                                    isConfirm = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      "Edit on Map",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        _getAddressForm(mediaQuery),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: mediaQuery.size.height *
                                  mapHeightFactorBeforeConfirm,
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
                            Positioned(
                              top: mediaQuery.size.height *
                                      mapHeightFactorBeforeConfirm -
                                  60,
                              left: mediaQuery.size.width - 65,
                              child: _gpsButton,
                            ),
                            Positioned(
                              top: mediaQuery.size.height / 4.3,
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
                                    child: const Column(
                                      children: [
                                       Padding(
                                          padding:
                                              EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            "Professional will arrive here",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2.0,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Move the pin to adjust",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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

  Widget get _confirmButtonWidget {
    return GestureDetector(
      onTap: () {
        setState(() {
          isConfirm = true;
        });
      },
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

  Widget get _addAddressButtonWidget {
    return GestureDetector(
      onTap: () {
        _saveForm();
      },
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
                    'Add Address',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  Widget get _googleMap => GoogleMap(
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(
          target: _latLng,
          zoom: 18,
        ),
        compassEnabled: true,
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomControlsEnabled: false,
        onCameraMove: (cameraPosition) {
          setState(() {
            _latLng = LatLng(cameraPosition.target.latitude,
                cameraPosition.target.longitude);
          });
        },
      );

  Widget get _gpsButton {
    var locationData = Provider.of<LocationProvider>(context, listen: false);
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        tooltip: 'Use GPS',
        icon: const Icon(Icons.gps_fixed),
        onPressed: () async {
          _moveToLocation(await locationData.getCurrentLocation());
        },
      ),
    );
  }

  Widget _getAddressForm(MediaQueryData mediaQuery) => Form(
        key: _key,
        child: Column(
          children: <Widget>[
            ListTile(
              subtitle: _addressTextFormField,
            ),
            ListTile(
              subtitle: _landmarkFormField,
            ),
            ListTile(
              subtitle: _contactFormField,
            ),
            ListTile(
              subtitle: _nameFormField,
            ),
            ListTile(
              subtitle: _titleFormField,
            ),
            _addAddressButtonWidget,
          ],
        ),
      );

  Future<void> _saveForm() async {
    if (!_key.currentState.validate()) return;
    _key.currentState.save();
    String title = _titleController.text.trim();
    String contactName = _nameController.text.trim();
    String contactNumber = _contactController.text.trim();
    String landmark = _landmarkController.text.trim();
    String addressText = _addressController.text.trim();
    _addressItem = AddressModel(
      title: title,
      id: null,
      addressText: addressText,
      contactName: contactName,
      contactNumber: contactNumber,
      landmark: landmark,
      lat: _latLng.latitude,
      lng: _latLng.longitude,
    );
    setState(() {
      loading = true;
    });
    try {
      final id = ModalRoute.of(context).settings.arguments;
      if (id == null) {
        await Provider.of<AddressProvider>(context, listen: false)
            .addAddress(_addressItem);
      } else {
        await Provider.of<AddressProvider>(context, listen: false)
            .updateAddress(_addressItem, id);
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _moveToLocation(LatLng location) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 17.5,
        ),
      ),
    );
    setState(() {
      _latLng = LatLng(location.latitude, location.longitude);
    });
  }

  void _initElements() {
    _addressItem = AddressModel(
      title: '',
      id: '',
      addressText: '',
      contactName: '',
      contactNumber: '',
      landmark: '',
      lat: null,
      lng: null,
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _landmarkFocusNode.dispose();
    _contactFocusNode.dispose();
    _titleFocusNode.dispose();
    _addressTextFocusNode.dispose();
    _titleController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _landmarkController.dispose();
    _addressController.dispose();
  }
}
