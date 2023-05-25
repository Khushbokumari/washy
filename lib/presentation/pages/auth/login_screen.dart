import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/network/url.dart';
import 'parentInfo.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  static const String routeName = 'login-screen';

  const LoginScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthBody(),
    );
  }
}

class AuthBody extends StatefulWidget {
  const AuthBody({Key key}) : super(key: key);

  @override
  AuthBodyState createState() => AuthBodyState();
}

class AuthBodyState extends State<AuthBody> {
  bool loading = false;
  bool dialogVisible = false;
  final controller = TextEditingController();
  final otpController = TextEditingController();
  String verId;

  @override
  void dispose() {
    controller.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.fill,
                width: mediaQuery.size.width * .9,
                height: mediaQuery.size.height * .5,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter 10 Digit Mobile Number",
                  prefixText: '+91 ',
                  labelText: 'Enter mobile number',
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              onPressed: loading ? null : _sendOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Send OTP'.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    final instance = FirebaseAuth.instance;
    setState(() {
      loading = true;
    });
    instance.verifyPhoneNumber(
      phoneNumber: '+91${controller.text}',
      timeout: const Duration(seconds: 30),
      verificationCompleted: (e) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(e);
          if (dialogVisible) {
            Navigator.of(context).pop();
          } else {
            showDialog(
              builder: (context) {
                return const AlertDialog(
                  title: Text('Success'),
                  content: Text('Auto login successful'),
                );
              },
              context: context,
            );
          }
        } catch (e) {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Auto verification failed'),
            ),
          );
        }
      },
      verificationFailed: (e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send Otp'),
          ),
        );
      },
      codeSent: (verId, [x]) async {
        setState(() {
          loading = false;
        });
        this.verId = verId;
        dialogVisible = true;
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: otpController,
                            decoration:
                                const InputDecoration(labelText: 'Enter Otp'),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: _enterOtp,
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
        dialogVisible = false;
      },
      codeAutoRetrievalTimeout: (e) {},
    );
  }

  Future<void> _enterOtp() async {
    Navigator.of(context).pop();
    setState(() {
      loading = true;
    });
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: verId, smsCode: otpController.text);
      await FirebaseAuth.instance.signInWithCredential(cred);
      // Navigator.of(context).pop();
      // _user.uid=FirebaseAuth.instance.currentUser.uid;
      String uid;
      FirebaseAuth.instance.authStateChanges().listen((event) async {
        if (event != null) {
          uid = event.uid;
        }
      });

      var url = "${URL.USER_INFO_URL}.json";
      bool uidFound = false;
      try {
        var response = await http.get(Uri.parse(url));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        responseData.forEach((key, val) {
          if (key == uid) {
            uidFound = true;
            if (val["name"] == null || val["email"] == null) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ParentInfo(controller.text, false),
                  ),
                  (route) => false);
            } else {
              //  Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            //  return;
          }
        });
        if (!uidFound) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ParentInfo(controller.text, true),
              ),
              (route) => false);
          //  Navigator.of(context).pushNamed(ParentInfo.routeName,arguments: ParentInfo(controller.text));
        }
      } catch (e) {
        log(e.toString());
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('LoginFailed'),
        ),
      );
    }
  }
}
