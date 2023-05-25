import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:washry/domain/transaction.dart';
import '../domain/transaction_history.dart';
import '../core/network/url.dart';
import '../presentation/pages/dashboard/dashboard_screen.dart';

// class AuthProvider with ChangeNotifier {
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   String _userId;
//   String _token;
//   StreamSubscription _subscription;
//
//   AuthProvider() {
//     _subscription = firebaseAuth.authStateChanges().listen((event) async {
//       if (event != null) {
//         _userId = event.uid;
//         _token = await event.getIdToken();
//       }
//       super.notifyListeners();
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   String get token => _token;
//
//   String get userId => _userId;
//
//   Future<bool> isAuth() async {
//     var user = firebaseAuth.currentUser;
//     return user == null ? false : true;
//   }
//
//   Future<void> logout() async {
//     await firebaseAuth.signOut();
//     notifyListeners();
//   }
//
//   setReffralStatus(context, String refferedByUid) async {
//     try {
//       const offerurl = "${URL.OFFERS_URL}.json";
//       final res = await http.get(Uri.parse(offerurl));
//       final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//       final userIdd = FirebaseAuth.instance.currentUser?.uid;
//       FirebaseDatabase.instance
//           .ref()
//           .child('referral')
//           .child(refferedByUid)
//           .update({userIdd: DateTime.now().toIso8601String()}).then(
//         (value) async {
//           int wallet = 0;
//           await FirebaseDatabase.instance
//               .ref()
//               .child("userInfo")
//               .child(refferedByUid)
//               .once()
//               .then((value) {
//             final val = value.snapshot.value as Map;
//             wallet = val["wallet"];
//           });
//           FirebaseDatabase.instance
//               .ref()
//               .child("userInfo")
//               .child(refferedByUid)
//               .update({"wallet": wallet + responseData["referralMoney"]});
//
//           FirebaseDatabase.instance
//               .ref()
//               .child("transaction")
//               .child(refferedByUid)
//               .update({"walletCoins": wallet + responseData["referralMoney"]});
//           TransactionHistory transactionHistory = TransactionHistory();
//           transactionHistory.date = DateTime.now();
//           transactionHistory.amount = responseData["referralMoney"];
//           transactionHistory.referral = "referral";
//           transactionHistory.credit = true;
//           transactionHistory.debit = false;
//           transactionHistory.title = "Referral Bonus Earned";
//           final urll = "${URL.TRANSACTION_URL}/$userId/transHistory.json";
//           await http.post(Uri.parse(urll),
//               body: jsonEncode(transactionHistory.toJson()));
//           final url = "${URL.TRANSACTION_URL}/$userId.json";
//           MoneyTransaction transaction = MoneyTransaction();
//           transaction.walletCoins = wallet + responseData["referralMoney"];
//           await http.patch(Uri.parse(url),
//               body: jsonEncode(transaction.toJson()));
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) =>  DashboardScreen(),
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
// }
// class AuthProvider with ChangeNotifier {
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   late String _userId;
//   late String _token;
//   late StreamSubscription _subscription;
//
//   AuthProvider() {
//     _subscription = firebaseAuth.authStateChanges().listen((event) async {
//       if (event != null) {
//         _userId = event.uid;
//         _token = await event.getIdToken();
//       }
//       super.notifyListeners();
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   String get token => _token;
//
//   String get userId => _userId;
//
//   Future<bool> isAuth() async {
//     var user = firebaseAuth.currentUser;
//     return user == null ? false : true;
//   }
//
//   Future<void> logout() async {
//     await firebaseAuth.signOut();
//     notifyListeners();
//   }
//
//   Future<void> setReffralStatus(BuildContext context, String refferedByUid) async {
//     try {
//       const offerurl = "${URL.OFFERS_URL}.json";
//       final res = await http.get(Uri.parse(offerurl));
//       final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//       final userIdd = FirebaseAuth.instance.currentUser?.uid;
//       FirebaseDatabase.instance
//           .ref()
//           .child('referral')
//           .child(refferedByUid)
//           .update({userIdd!: DateTime.now().toIso8601String()}).then(
//             (value) async {
//           int wallet = 0;
//           await FirebaseDatabase.instance
//               .ref()
//               .child("userInfo")
//               .child(refferedByUid)
//               .once()
//               .then((value) {
//             final val = value.snapshot.value as Map;
//             wallet = val["wallet"];
//           });
//           FirebaseDatabase.instance
//               .ref()
//               .child("userInfo")
//               .child(refferedByUid)
//               .update({"wallet": wallet + responseData["referralMoney"]});
//
//           FirebaseDatabase.instance
//               .ref()
//               .child("transaction")
//               .child(refferedByUid)
//               .update({"walletCoins": wallet + responseData["referralMoney"]});
//           TransactionHistory transactionHistory = TransactionHistory();
//           transactionHistory.date = DateTime.now();
//           transactionHistory.amount = responseData["referralMoney"].toDouble();
//           transactionHistory.referral = "referral";
//           transactionHistory.credit = true;
//           transactionHistory.debit = false;
//           transactionHistory.title = "Referral Bonus Earned";
//           final urll = "${URL.TRANSACTION_URL}/$userId/transHistory.json";
//           await http.post(Uri.parse(urll),
//               body: jsonEncode(transactionHistory.toJson()));
//           final url = "${URL.TRANSACTION_URL}/$userId.json";
//           MoneyTransaction transaction = MoneyTransaction();
//           // transaction.walletCoins = wallet + responseData["referralMoney"];//bug
//           await http.patch(Uri.parse(url),
//               body: jsonEncode(transaction.toJson()));
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => DashboardScreen(),
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
// }
class AuthProvider with ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late String _userId;
  late String _token;
  late StreamSubscription _subscription;

  AuthProvider() {
    _subscription = firebaseAuth.authStateChanges().listen((event) async {
      if (event != null) {
        _userId = event.uid;
        _token = await event.getIdToken();
      }
      super.notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String get token => _token;

  String get userId => _userId;

  Future<bool> isAuth() async {
    var user = firebaseAuth.currentUser;
    return user == null ? false : true;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
    notifyListeners();
  }

  Future<void> setReffralStatus(BuildContext context, String refferedByUid) async {
    try {
      const offerurl = "${URL.OFFERS_URL}.json";
      final res = await http.get(Uri.parse(offerurl));
      final responseData = jsonDecode(res.body) as Map<String, dynamic>;
      final userIdd = FirebaseAuth.instance.currentUser?.uid;
      FirebaseDatabase.instance
          .ref()
          .child('referral')
          .child(refferedByUid)
          .update({userIdd!: DateTime.now().toIso8601String()}).then(
            (value) async {
          int wallet = 0;
          await FirebaseDatabase.instance
              .ref()
              .child("userInfo")
              .child(refferedByUid)
              .once()
              .then((value) {
            final val = value.snapshot.value as Map;
            wallet = val["wallet"];
          });
          FirebaseDatabase.instance
              .ref()
              .child("userInfo")
              .child(refferedByUid)
              .update({"wallet": wallet + responseData["referralMoney"].toDouble()});

          FirebaseDatabase.instance
              .ref()
              .child("transaction")
              .child(refferedByUid)
              .update({"walletCoins": wallet + responseData["referralMoney"].toDouble()});
          TransactionHistory transactionHistory = TransactionHistory();
          transactionHistory.date = DateTime.now();
          transactionHistory.amount = responseData["referralMoney"].toDouble();
          transactionHistory.referral = "referral";
          transactionHistory.credit = true;
          transactionHistory.debit = false;
          transactionHistory.title = "Referral Bonus Earned";
          final urll = "${URL.TRANSACTION_URL}/$userId/transHistory.json";
          await http.post(Uri.parse(urll),
              body: jsonEncode(transactionHistory.toJson()));
          final url = "${URL.TRANSACTION_URL}/$userId.json";
          MoneyTransaction transaction = MoneyTransaction();
          // transaction.walletCoins = wallet + responseData["referralMoney"].toDouble();
          await http.patch(Uri.parse(url),
              body: jsonEncode(transaction.toJson()));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>  DashboardScreen(),
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
