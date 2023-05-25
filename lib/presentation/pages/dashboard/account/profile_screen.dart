import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/network/url.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'Profile-Screen';

  const ProfileScreen({Key ?key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingControllerforemail =
      TextEditingController();
  final TextEditingController _textEditingControllerforPhone =
      TextEditingController();
  Map<String, dynamic> k = {};
  FocusNode nameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  bool isLoading = false;
  @override
  void initState() {
    mapDataget();

    super.initState();
  }

  bool _isEnable = false;
  bool _isEnableEmail = false;
  final bool _isEnablePhone = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool valid = true;
  bool emailvalid = true;
  @override
  Widget build(BuildContext context) {
    // String name;
    // String email;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: !isLoading
            ? SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .04,
                      ),

                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: height * .035,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                  // color: Colors.white,

                                  borderRadius: BorderRadius.circular(10)),
                              width: width * .8,
                              height: orientation == Orientation.portrait
                                  ? height * .07
                                  : height * .16,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        // color: Colors.grey,
                                        border: Border.all(
                                            width: 2,
                                            color: valid
                                                ? Colors.black
                                                : Colors.red),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            height: orientation ==
                                                    Orientation.portrait
                                                ? height * .04
                                                : height * .1,
                                            width: orientation ==
                                                    Orientation.portrait
                                                ? width * .575
                                                : width * .7,
                                            child: TextFormField(
                                              focusNode: nameNode,
                                              controller:
                                                  _textEditingController,
                                              onChanged: (val) {
                                                if (val.trim().isEmpty) {
                                                  valid = false;

                                                  return;
                                                } else {
                                                  valid = true;
                                                }
                                                return;
                                              },
                                              validator: (val) {
                                                if (val.isEmpty) {
                                                  return 'This field can\'t be empty';
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                                hintText: 'Full name',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[600]),
                                                enabled: _isEnable,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              setState(() {
                                                _isEnable = true;
                                                if (_isEnable) {
                                                  nameNode.requestFocus();
                                                }
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      top: orientation == Orientation.portrait
                                          ? -height * .01
                                          : -height * .019,
                                      left: width * .03,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * .035,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              width: width * .8,
                              height: orientation == Orientation.portrait
                                  ? height * .07
                                  : height * .16,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: emailvalid
                                                ? Colors.black
                                                : Colors.red),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            height: orientation ==
                                                    Orientation.portrait
                                                ? height * .03
                                                : height * .07,
                                            width: orientation ==
                                                    Orientation.portrait
                                                ? width * .575
                                                : width * .7,
                                            child: TextFormField(
                                                focusNode: emailNode,
                                                controller:
                                                    _textEditingControllerforemail,
                                                validator: (val) {
                                                  if (val.isEmpty) {
                                                    emailvalid = false;
                                                    return null;
                                                  } else if (!val
                                                      .contains('@')) {
                                                    return 'invalid email';
                                                  } else {
                                                    emailvalid = true;

                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  // hintText: "Email",
                                                  // labelText: "Email",
                                                  // enabledBorder:InputBorder(borderSide: BorderStyle.solid),
                                                  labelStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  enabled: _isEnableEmail,
                                                )),
                                          ),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              setState(() {
                                                _isEnableEmail = true;
                                                if (_isEnableEmail) {
                                                  emailNode.requestFocus();
                                                }
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      top: orientation == Orientation.portrait
                                          ? -height * .01
                                          : -height * .019,
                                      left: width * .03,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Text(
                                            'Email',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * .035,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              width: width * .8,
                              height: orientation == Orientation.portrait
                                  ? height * .07
                                  : height * .16,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                    height: orientation == Orientation.portrait
                                        ? height * .07
                                        : height * .135,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            height: orientation ==
                                                    Orientation.portrait
                                                ? height * .06
                                                : height * .09,
                                            width: width * .6,
                                            child: TextFormField(
                                                focusNode: phoneNode,
                                                // style: TextStyle(decorationStyle: ),
                                                controller:
                                                    _textEditingControllerforPhone,
                                                validator: (val) {
                                                  if (val.isEmpty) {
                                                    return "Enter Phone number";
                                                  } else if (val.length != 10) {
                                                    return 'invalid Phone number';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Phone Number",
                                                  // focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ,
                                                  // labelText: "Phone Number",
                                                  labelStyle: const TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  enabled: _isEnablePhone,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      top: orientation == Orientation.portrait
                                          ? -height * .01
                                          : -height * .019,
                                      left: width * .03,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Text(
                                            'Mobile No.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * .46,
                            ),
                            SizedBox(
                                width: width * .75,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                    Colors.red,
                                  )),
                                  onPressed: () async {
                                    if (valid == true &&
                                        emailvalid == true &&
                                        formKey.currentState.validate()) {
                                      final userIdd =
                                          FirebaseAuth.instance.currentUser.uid;
                                      var url =
                                          "${URL.USER_INFO_URL}/$userIdd.json";
                                      await http.patch(Uri.parse(url),
                                          body: jsonEncode({
                                            "name": _textEditingController.text,
                                            "email":
                                                _textEditingControllerforemail
                                                    .text
                                          }));

                                      await Fluttertoast.showToast(
                                        msg: "Updated",
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                    }
                                  },
                                  child: const Text("Save Changes"),
                                ))
                          ],
                        ),
                      ),
                      // ),
                    ],
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  mapDataget() async {
    setState(() {
      isLoading = true;
    });
    final userIdd = FirebaseAuth.instance.currentUser.uid;

    final url = "${URL.USER_INFO_URL}/$userIdd.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    k["name"] = responseData["name"];
    k["email"] = responseData["email"];
    k["phone"] = responseData["phoneNumber"];

    _textEditingController.text = k["name"];
    _textEditingControllerforemail.text = k["email"];
    _textEditingControllerforPhone.text = k["phone"];

    setState(() {
      isLoading = false;
    });
  }
}
