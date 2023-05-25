import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:validate/validate.dart';
import '../../../core/network/url.dart';
import 'package:washry/domain/user_info.dart';
import 'package:http/http.dart' as http;
import 'package:washry/application/auth.dart';
import '../location/location_search_screen.dart';

class ParentInfo extends StatefulWidget {
  static const String routeName = 'parent-info';
  final String phoneNumber;
  final bool isNewUser;
  const ParentInfo(this.phoneNumber, this.isNewUser, {Key key})
      : super(key: key);
  @override
  ParentInfoState createState() => ParentInfoState();
}

class ParentInfoState extends State<ParentInfo> {
  final UserInf _user = UserInf();
  String email = "";
  String name = "";
  String referral = "";
  String userId;
  final controller = TextEditingController();
  bool isLoading = false;

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        userId = event.uid;
      }
    });
    _user.phoneNumber = widget.phoneNumber;
    return MaterialApp(
      home: SafeArea(
          child: Scaffold(
              body: !isLoading
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: height * 0.32,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage('assets/images/app_logo.png'),
                            )),
                          ),
                          const SizedBox(height: 5),
                          const Padding(
                            padding: EdgeInsets.only(
                                bottom: 8, right: 0, left: 20, top: 8),
                            child: Text(
                              'Welcome back',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          //SizedBox(height: 3),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8, right: 0, left: 20, top: 0),
                            child: Text(
                              'Sign Up With',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          Form(
                            key: _key,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 22),
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800]),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[300],
                                    ),
                                    margin: const EdgeInsets.only(top: 7),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: TextFormField(
                                      onChanged: (val) {
                                        name = val;
                                        _user.name = val;
                                      },
                                      validator: (val) {
                                        if (val.isEmpty) {
                                          return "Please enter your name";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your name',
                                        fillColor: Colors.grey,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Email',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[300],
                                    ),
                                    margin: const EdgeInsets.only(top: 7),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: TextFormField(
                                      keyboardType: TextInputType
                                          .emailAddress, // Use email input type for emails.
                                      decoration: const InputDecoration(
                                        hintText: 'you@example.com',
                                        border: InputBorder.none,
                                      ),
                                      validator: (String value) {
                                        try {
                                          Validate.isEmail(value);
                                        } catch (e) {
                                          return 'The E-mail Address must be a valid email address.';
                                        }
                                        return null;
                                      },
                                      onChanged: (val) {
                                        email = val;
                                        _user.wallet = 0;
                                        _user.email = val;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Phone No.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[300],
                                    ),
                                    width: double.infinity,
                                    height: 47,
                                    margin: const EdgeInsets.only(top: 7),
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 14, right: 15),
                                    child: Text(
                                      widget.phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  widget.isNewUser
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 18),
                                            const Text(
                                              'Refferral Code',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.grey[300],
                                              ),
                                              margin:
                                                  const EdgeInsets.only(top: 7),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Referral Code',
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (val) {
                                                  referral = val;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: width,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_key.currentState.validate()) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          var url =
                                              "${URL.USER_INFO_URL}/$userId.json";
                                          await http.patch(Uri.parse(url),
                                              body: jsonEncode(_user.toJson()));
                                          if (referral.length == 4) {
                                            String val = referral;
                                            if (val.length == 4) {
                                              const url =
                                                  "${URL.USER_INFO_URL}.json";
                                              final response = await http
                                                  .get(Uri.parse(url));
                                              final data =
                                                  jsonDecode(response.body)
                                                      as Map<String, dynamic>;

                                              (data).forEach((key, value) {
                                                if (key
                                                        .toString()
                                                        .substring(0, 4) ==
                                                    val) {
                                                  setState(() async {
                                                    String refferedByUid = key;
                                                    await AuthProvider()
                                                        .setReffralStatus(
                                                            context,
                                                            refferedByUid
                                                                .toString());
                                                    // ignore: use_build_context_synchronously
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LocationSearchScreen(),
                                                        ));
                                                  });
                                                } else {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LocationSearchScreen(),
                                                  ));
                                                }
                                              });
                                            }
                                          } else {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LocationSearchScreen(),
                                              ),
                                            );
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        child: Text("Sign Up"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ))),
    );

//                           decoration: const InputDecoration(
//                             icon: const Icon(Icons.person),
//                             hintText: 'Enter your name',
//                             labelText: 'Name',
//                           ),
//                         ),
//                         Container(
//                           margin:
//                               EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                           child: Text(
//                             widget.phoneNumber,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ),
//                         TextFormField(
//                           keyboardType: TextInputType
//                               .emailAddress, // Use email input type for emails.
//                           decoration: new InputDecoration(
//                               hintText: 'you@example.com',
//                               labelText: 'E-mail Address'),
//                           validator: (String value) {
//                             try {
//                               Validate.isEmail(value);
//                             } catch (e) {
//                               return 'The E-mail Address must be a valid email address.';
//                             }
//                             return null;
//                           },
//                           onChanged: (val) {
//                             email = val;
//                             _user.wallet = 0;
//                             _user.email = val;
//                           },
//                         ),
//                         widget.isNewUser?
//                         TextFormField(
//                           decoration: new InputDecoration(
//                             hintText: 'Referral Code',
//                           ),
//                           onChanged: (val) {
//                             referral = val;
//                           },
//                         ):Container(),
//                         Container(
//                           width: _width * 0.3,
//                           child: ElevatedButton(
//                             style: ButtonStyle(
//                               elevation: MaterialStateProperty.all(0),
//                               shape: MaterialStateProperty.all(
//                                   RoundedRectangleBorder(
//                                       side: BorderSide(color: Colors.blue),
//                                       borderRadius: BorderRadius.circular(8))),
//                             ),

//                             child: Text("Submit"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Center(
//                     child: CircularProgressIndicator(),
//                   )));
  }
}
