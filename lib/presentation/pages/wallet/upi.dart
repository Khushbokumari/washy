// import 'dart:convert';
// import 'dart:developer';
// import 'dart:ui';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:upi_india/upi_app.dart';
// import 'package:upi_india/upi_india.dart';
// import 'package:washry/domain/transaction.dart';
// import 'package:washry/domain/transaction_history.dart';
// import 'package:washry/domain/url.dart';
// import 'package:http/http.dart' as http;

// class UpiScreen extends StatefulWidget {
//   // const UpiScreen({ Key? key }) : super(key: key);
//   String amount;
//   UpiScreen(this.amount);
//   @override
//   _UpiScreenState createState() => _UpiScreenState();
// }

// class _UpiScreenState extends State<UpiScreen> {
//   List<UpiApp> options = [];
//   UpiIndia upiIndia = UpiIndia();
//   @override
//   void initState() {
//     upiIndia.getAllUpiApps().then((value) {
//       options = value;
//       setState(() {});
//       log(value.toString());
//       value.forEach((element) {
//         log(element.name.toString());
//       });
//     });
//     super.initState();
//   }

//   Future<UpiResponse> initiateTransaction(UpiApp app) async {
//     return upiIndia.startTransaction(
//       app: app,
//       receiverUpiId: "8630598001@ybl",
//       receiverName: 'Amit Upadhyay',
//       transactionRefId: 'TestingUpiIndiaPlugin',
//       transactionNote: 'Not actual. Just an example.',
//       amount: double.parse(widget.amount),
//     );
//   }
//   //abb iss screen pe ye jo uper list h upi apps ki usko print kra do then ji banda choose krega uske hisab se
//   // iss fx me vo app pass kr dena then response le lena agr vo success h to firebase me update
//   // nai to try catch lga ke back + error payment failed
//   //bass

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: options.length,
//             itemBuilder: (ctx, index) => Container(
//                     child: InkWell(
//                   onTap: () {
//                     try {
//                       initiateTransaction(options[index]).then((value) async {
//                         if (value.status == "failure") {
//                           showDialog(
//                               context: context,
//                               builder: (ctx) => AlertDialog(
//                                     title: Text("payment failed"),
//                                   ));
//                         } else if (value.status == "success") {
//                           await updatewalletmoney();
//                         } else {}
//                       });
//                     } catch (r) {
//                       log(r.toString());
//                     }
//                   },
//                   child: Container(width: 100,child: Image.memory(options[index].icon,height: 10,width: 10,)),
//                 ))));
//   }

//   updatewalletmoney() async {
//     double amount = double.parse(widget.amount);
//     double prevWallet = 0;
//     final userId =
//         await FirebaseAuth.instance.currentUser().then((value) => value.uid);
//     try {
//       final transUrl = URL.TRANSACTION_URL + ".json";
//       final res = await http.get(transUrl);
//       final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//       log("amit".toString());
//       if (responseData != null) {
//         responseData.forEach((key, value) {
//           if (key == userId) {
//             prevWallet = value["walletMoney"];
//           }
//         });
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//     final offerurl = URL.OFFERS_URL +"/moneyOffers"+ ".json";
//     final res = await http.get(offerurl);
//     final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//     int offerMoney = 0;
//     responseData.forEach((key, value) {
//       int k = int.parse(key);
//       if (amount >= k) {
//         offerMoney = value;
//       }
//     });

//     final url = URL.TRANSACTION_URL + "/$userId" + ".json";
//     final urll = URL.TRANSACTION_URL + "/$userId" + "/transHistory" + ".json";
//     Transaction transaction = new Transaction();
//     transaction.walletMoney = amount + prevWallet + offerMoney;
//     // TransactionHistory transactionHistory = new TransactionHistory();
//     transactionHistory.date =DateTime.now();
//     //     "-" +
//     //     DateTime.now().month.toString() +
//     //     "-" +
//     //     DateTime.now().year.toString();
//     transactionHistory.amount = amount + offerMoney;
//     // transaction.transactionHistory = transactionHistory;
//     await http.patch(url, body: jsonEncode(transaction.toJson()));
//     final result =
//         await http.post(urll, body: jsonEncode(transactionHistory.toJson()));
//   }
// }
