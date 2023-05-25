// import 'dart:convert';
// import 'dart:developer';
// import 'package:cashfree_pg/cashfree_pg.dart';
// // import '';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:washry/domain/transaction.dart';
// import 'package:washry/domain/transaction_history.dart';
// import 'package:washry/domain/url.dart';
// import 'package:http/http.dart' as http;
// import 'package:washry/application/serviceIds.dart';

// class ProceedToPay extends StatefulWidget {
//   // static const String routeName = 'proceedToPay';
//   double walletMoney;
//   String upiId;
//   String upiName;
//   String client_id;
//   String client_secret;
//   int maxWalletMoney;

//   // String amount;
//   // UpiScreen(this.amount);
//   ProceedToPay(this.walletMoney, this.upiId, this.upiName, this.maxWalletMoney,this.client_id,this.client_secret);
//   @override
//   _ProceedToPayState createState() => _ProceedToPayState();
// }

// class _ProceedToPayState extends State<ProceedToPay> {
//   String phoneNumber = "1234567890";
//   int offerMoneyVal = 0;

//   getPhoneNumber() async {
//     String uid;
//     FirebaseAuth.instance.currentUser().then((value) async {
//       uid = value.uid;
//       var url = URL.USER_INFO_URL + "/$uid" + ".json";
//       final response = await http.get(url);
//       log("uid ${response.body}");
//       var responseDataOfUserInfo =
//           jsonDecode(response.body) as Map<String, dynamic>;
//       phoneNumber = responseDataOfUserInfo['phoneNumber'];
//       log("success");
//       setState(() {});
//       log(phoneNumber.toString());
//     });
//   }

//   @override
//   void initState() {
//     getPhoneNumber();
//     super.initState();
//   }
//   TextEditingController _textEditingController = TextEditingController();
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   bool isValidAmount = false;

//   final controller = PageController();
//   int amountTotal = 0;
//   int totaleAmountPay = 0;
//   int newTotaleAmountPay = 0;
//   int walletAmount = 0;
//   int walletAmountLeft = 0;
//   int packingCharges = 0;
//   int gstCharge = 0;
//   int subTotal = 0;
//   // int discount_amount = 0;
//   // String coupon_code = "";
//   // int chef_Id;
//   bool walletApplied = false;
//   // bool _visible;
//   void _showErrorDialog(String error) {
//     showDialog(
//         context: context,
//         builder: (ctx) {
//           return AlertDialog(
//             title: Text('Unable to add'),
//             content: Text(error),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('Okay'),
//                 onPressed: () => Navigator.of(context).pop(),
//               )
//             ],
//           );
//         });
//   }

//   generateToken() async {
//     String orderId = Uuid().v4().substring(4);
//     Uri url = Uri.parse('https://test.cashfree.com/api/v2/cftoken/order');
//     http.Response res = await http.post(url,
//         headers: {
//           'x-client-id': widget.client_id,
//           'x-client-secret': widget.client_secret
//         },
//         body: json.encode({
//           "orderId": orderId,
//           "orderAmount": totaleAmountPay,
//           "orderCurrency": "INR"
//         }));
//     log(res.statusCode.toString());
//     if (res.statusCode == 200) {
//       Map<String, dynamic> map = json.decode(res.body);

//       String stage = "TEST";
//       String orderAmount = totaleAmountPay.toString();
//       String tokenData = map['cftoken'];

//       String orderNote = "Order_Note";
//       String orderCurrency = "INR";
//       String appId = "992203c3565c977cfcdfe872a02299";

//       String notifyUrl = "https://test.gocashfree.com/notify";
//       Map<String, dynamic> inputParams = {
//         "orderId": orderId,
//         "orderAmount": orderAmount,
//         "customerName": "Aryan Koshik",
//         "orderNote": orderNote,
//         "orderCurrency": orderCurrency,
//         "appId": appId,
//         "customerPhone": phoneNumber,
//         "customerEmail": "amitsh223@gmail.com",
//         "stage": stage,
//         "tokenData": tokenData,
//         "hideOrderId": true,
//       };
//       CashfreePGSDK.doPayment(inputParams).then((value) async {
//         log('vlaue dsiofj  kj'+value.toString());
//         if (value['txStatus'] == 'SUCCESS') {
//           String referenceId=value['referenceId'];

//           await updatewalletmoney(orderId,referenceId);
//         } else {
//           Fluttertoast.showToast(
//             msg: "An error occured",
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final svcId = Provider.of<ServiceIds>(context, listen: false);
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     Orientation orientation = MediaQuery.of(context).orientation;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Money"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               height: orientation == Orientation.portrait
//                   ? height * 0.01
//                   : height * 0.03,
//             ),
//             Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.only(left: 25.0, bottom: 25, top: 15),
//                   alignment: Alignment.topLeft,
//                   child: Image.asset(
//                     'assets/images/app_logo.png',
//                     fit: BoxFit.fill,
//                     width: orientation == Orientation.portrait
//                         ? width * 0.2
//                         : width * 0.10,
//                     height: orientation == Orientation.portrait
//                         ? height * 0.08
//                         : height * 0.18,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 15.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                           child: Text(
//                         "WASHRY MONEY",
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       )),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5.0),
//                         child: Container(
//                             child: Text(
//                           "Available balance: " +
//                               "\u{20B9}" +
//                               svcId.walletMoney.toInt().toString(),
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         )),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 5.0),
//                         child: Container(
//                           child: Text(
//                             "You can add upto " +
//                                 "\u{20B9}" +
//                                 (widget.walletMoney <= widget.maxWalletMoney
//                                         ? (widget.maxWalletMoney -
//                                             svcId.walletMoney)
//                                         : 0)
//                                     .toInt()
//                                     .toString(),
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 15.0, right: 15),
//                   child: Form(
//                     key: formKey,
//                     child: TextFormField(
//                         controller: _textEditingController,
//                         // ignore: deprecated_member_use
//                         inputFormatters: [
//                           WhitelistingTextInputFormatter.digitsOnly
//                         ],
//                         keyboardType:
//                             TextInputType.numberWithOptions(decimal: false),
//                         validator: (val) {
//                           int money = int.tryParse(val);
//                           if (val.trim().isEmpty) {
//                             return "Enter Amount";
//                           } else if (money == null)
//                             return null;
//                           else if (money >
//                               (widget.maxWalletMoney - widget.walletMoney)) {
//                             return null;
//                           } else
//                             return null;
//                         },
//                         decoration: InputDecoration(
//                           // border: InputBorder.none,
//                           labelText: "ENTER AMOUNT",
//                           prefixText: "\u{20B9}",
//                           // hintText: "Amount",
//                           labelStyle:
//                               TextStyle(color: Colors.grey, fontSize: 12),
//                         )),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: orientation == Orientation.portrait
//                   ? height * 0.04
//                   : height * 0.07,
//             ),
//             //     isValidAmount==false?Fluttertoast.showToast(
//             //     msg: "Not Available",
//             //     toastLength: Toast.LENGTH_SHORT,

//             // ) :
//             Container(
//               width: width * .9,
//               height: orientation == Orientation.portrait
//                   ? height * 0.055
//                   : height * 0.13,
//               child: ElevatedButton(
//                   child: Text("PROCEED TO ADD MONEY"),
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.blue,
//                     shape: new RoundedRectangleBorder(
//                       borderRadius: new BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   onPressed: () {
//                     if (formKey.currentState.validate()) {
//                       totaleAmountPay = int.parse(_textEditingController.text);

//                       if (svcId.walletMoney.toInt() + totaleAmountPay > 10000) {
//                         _showErrorDialog(
//                             "You can't add more than ${widget.maxWalletMoney} in wallet");
//                         return;
//                       }

//                       generateToken();
//                     }
//                   }),
//             ),
//             SizedBox(
//               height: height * .03,
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 20),
//               child: Column(
//                 children: [
//                   Container(
//                       alignment: Alignment.topLeft,
//                       child: Text(
//                         "NOTE:",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       )),
//                   Row(
//                     children: [
//                       Container(
//                         height: height * .008,
//                         width: width * .017,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(50),
//                             color: Colors.black),
//                       ),
//                       SizedBox(
//                         width: width * .02,
//                       ),
//                       Column(
//                         children: [
//                           SizedBox(
//                             height: height * .02,
//                           ),
//                           Container(
//                               width: width * .9,
//                               child: Text(
//                                 "Washry Money cannot be transferred to your bank account as per RBI guidelines.",
//                                 style: TextStyle(
//                                     fontSize: 13, color: Colors.grey[600]),
//                               ))
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: height * .01,
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         height: height * .008,
//                         width: width * .017,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(50),
//                             color: Colors.black),
//                       ),
//                       SizedBox(
//                         width: width * .02,
//                       ),
//                       Container(
//                           width: width * .9,
//                           child: Text(
//                             "Washry Money can be used for your cleaning or orders",
//                             style: TextStyle(
//                                 fontSize: 12, color: Colors.grey[600]),
//                           ))
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(height: height * 0.05),
//           ],
//         ),
//       ),
//     );
//   }

//   // void _modalBottomSheetMenu4() {
//   //   showModalBottomSheet(
//   //       context: context,
//   //       shape: RoundedRectangleBorder(
//   //         borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//   //       ),
//   //       builder: (BuildContext context) {
//   //         int _index = 0;
//   //         final width = MediaQuery.of(context).size.width;
//   //         final height = MediaQuery.of(context).size.height;
//   //         var orientation = MediaQuery.of(context).orientation;
//   //         var count = (options.length / 4).ceil();
//   //         return Container(
//   //           height: orientation == Orientation.portrait
//   //               ? height * 0.37
//   //               : height * 0.67,
//   //           child: SingleChildScrollView(
//   //             child: Column(
//   //               children: [
//   //                 SizedBox(
//   //                   height: height * .03,
//   //                 ),
//   //                 Text(
//   //                   "Payment Options",
//   //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//   //                 ),
//   //                 SizedBox(
//   //                   height: orientation == Orientation.portrait
//   //                       ? height * 0.01
//   //                       : height * 0.03,
//   //                 ),
//   //                 Container(
//   //                   height: orientation == Orientation.portrait
//   //                       ? height * 0.12
//   //                       : height * 0.25,
//   //                   width: width * 0.8,
//   //                   child: PageView.builder(
//   //                       scrollDirection: Axis.horizontal,
//   //                       itemCount: (options.length / 4).ceil(),
//   //                       controller: controller,
//   //                       itemBuilder: (ctx, idx) {
//   //                         return ListView.builder(
//   //                             shrinkWrap: true,
//   //                             physics: NeverScrollableScrollPhysics(),
//   //                             scrollDirection: Axis.horizontal,
//   //                             itemCount: (options.length / 4).ceil() == idx + 1
//   //                                 ? (options.length % 4) == 0
//   //                                     ? 4
//   //                                     : (options.length % 4)
//   //                                 : 4,
//   //                             itemBuilder: (BuildContext ctx, index) {
//   //                               return Row(
//   //                                 children: [
//   //                                   Container(
//   //                                     // color: Colors.green,
//   //                                     child: InkWell(
//   //                                       onTap: () {
//   //                                         try {
//   //                                           doUpiTransation(options[index])
//   //                                               .then((value) async {
//   //                                             if (value.status == "failure") {
//   //                                               showDialog(
//   //                                                   context: context,
//   //                                                   builder: (ctx) =>
//   //                                                       AlertDialog(
//   //                                                         title: Text(
//   //                                                             "payment failed"),
//   //                                                       ));
//   //                                             } else if (value.status ==
//   //                                                 "success") {
//   //                                               await updatewalletmoney(
//   //                                                   value.transactionRefId);
//   //                                             } else {}
//   //                                           });
//   //                                         } catch (r) {
//   //                                           log(r.toString());
//   //                                         }
//   //                                       },
//   //                                       child: Container(
//   //                                           decoration: BoxDecoration(
//   //                                               // color: Colors.red,
//   //                                               borderRadius:
//   //                                                   BorderRadius.circular(10)),
//   //                                           width: orientation ==
//   //                                                   Orientation.portrait
//   //                                               ? width * .2
//   //                                               : width * .2,
//   //                                           height: orientation ==
//   //                                                   Orientation.portrait
//   //                                               ? height * .2
//   //                                               : height * 0.2,
//   //                                           child: Column(
//   //                                             children: [
//   //                                               Image.memory(
//   //                                                 options[index + 4 * idx].icon,
//   //                                                 height: orientation ==
//   //                                                         Orientation.portrait
//   //                                                     ? 60
//   //                                                     : 50,
//   //                                                 width: 40,
//   //                                               ),
//   //                                               Container(
//   //                                                 margin:
//   //                                                     EdgeInsets.only(left: 7),
//   //                                                 child: Text(
//   //                                                     options[index + 4 * idx]
//   //                                                         .upiApplication.getAppName()),
//   //                                               )
//   //                                             ],
//   //                                           )),
//   //                                     ),
//   //                                   ),
//   //                                 ],
//   //                               );
//   //                             });
//   //                       }),
//   //                 ),
//   //                 // SizedBox(
//   //                 //   height: height * .027,
//   //                 // ),
//   //                 (options.length / 4).ceil() > 1
//   //                     ? SmoothPageIndicator(
//   //                         count: (options.length / 4).ceil(),
//   //                         controller: controller,
//   //                         effect: JumpingDotEffect(dotWidth: 10, dotHeight: 10),
//   //                       )
//   //                     : SizedBox(),
//   //                 SizedBox(
//   //                   height: height * .05,
//   //                 ),
//   //                 InkWell(
//   //                     onTap: () {
//   //                       Navigator.of(context).pop();
//   //                     },
//   //                     child: Container(
//   //                       alignment: Alignment.center,
//   //                       width: width * .78,
//   //                       height: orientation == Orientation.portrait
//   //                           ? height * 0.06
//   //                           : height * 0.12,
//   //                       child: Text(
//   //                         "Cancel",
//   //                         style: TextStyle(
//   //                             color: Colors.grey[600],
//   //                             fontWeight: FontWeight.w500),
//   //                       ),
//   //                       decoration: BoxDecoration(
//   //                           borderRadius: BorderRadius.circular(30),
//   //                           color: Colors.grey[200]),
//   //                     ))
//   //               ],
//   //             ),
//   //           ),
//   //         );
//   //       });
//   // }

//   updatewalletmoney(String refId,String paymentId) async {
//     log("ashu" + refId);
//     double amount = double.parse(_textEditingController.text);
//     double prevWallet = 0;
//     double prevWalletCoins = 0.0;
//     final userId =
//         await FirebaseAuth.instance.currentUser().then((value) => value.uid);

//     log(userId.toString());
//     try {
//       final transUrl = URL.TRANSACTION_URL + ".json";
//       final res = await http.get(transUrl);
//       final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//       if (responseData != null) {
//         responseData.forEach((key, value) {
//           if (key == userId) {
//             log(prevWalletCoins.toString());

//             prevWallet = value["walletMoney"] ?? 0.0;
//             if (value["walletCoins"] != null) {
//               prevWalletCoins = value["walletCoins"] * 1.0;
//             }
//             // if(prevWalletCoins!=null){
//             //   prevWalletCoins=prevWalletCoins*1.0;
//             // }
//             log("hhhhh  " + prevWalletCoins.toString());
//           }
//         });
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//     final offerurl = URL.OFFERS_URL + "/moneyOffers" + ".json";
//     final res = await http.get(offerurl);
//     final responseData = jsonDecode(res.body) as Map<String, dynamic>;
//     int offerMoney = 0;
//     responseData.forEach((key, value) {
//       int k = int.parse(key);
//       if (amount >= k) {
//         offerMoney = value;
//       }
//     });
//     setState(() {
//       offerMoneyVal = offerMoney;
//     });
//     //
//     widget.walletMoney = widget.walletMoney +
//         int.parse(_textEditingController.text) +
//         offerMoneyVal;
//     final svcId = Provider.of<ServiceIds>(context, listen: false);
//     svcId.updateWalletMoney(widget.walletMoney);
//     _textEditingController.clear();
//     setState(() {});

//     log(amount.toString() + "  oo  " + offerMoney.toString());
//     final url = URL.TRANSACTION_URL + "/$userId" + ".json";
//     final urll = URL.TRANSACTION_URL + "/$userId" + "/transHistory" + ".json";
//     Transaction transaction = new Transaction();
//     transaction.walletMoney = amount + prevWallet + offerMoney;
//     transaction.walletCoins = prevWalletCoins;
//     TransactionHistory transactionHistory = new TransactionHistory();
//     transactionHistory.date = DateTime.now();
//     transactionHistory.amount = amount + offerMoney;
//     transactionHistory.transactionRefId = refId;
//     transactionHistory.credit = true;
//     transactionHistory.debit = false;
//     transactionHistory.title = "Wallet recharge";
//     transactionHistory.paymentId=paymentId;
//     // log(transaction.dwalletMoney.toString());
//     // transaction.transactionHistory = transactionHistory;
//     await http.patch(url, body: jsonEncode(transaction.toJson()));
//     final result =
//         await http.post(urll, body: jsonEncode(transactionHistory.toJson()));
//     log(result.toString());
//   }
// }
