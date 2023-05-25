import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:washry/domain/transaction_history.dart';
import '../../../core/network/url.dart';
import '../../../presentation/pages/wallet/supportScreen.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class WalletMoneyScreen extends StatefulWidget {
  List<String> questions = [];
  List<String> answers = [];
  List<String> coinQuestions = [];
  List<String> coinAnswers = [];
  String transactionId;
  double addedAmount;
  String title;
  String orderId;
  TransactionHistory transactionHistory;
  WalletMoneyScreen(
      this.transactionHistory,
      this.transactionId,
      this.addedAmount,
      this.questions,
      this.answers,
      this.coinQuestions,
      this.coinAnswers,
      this.title,
      this.orderId, {Key key}) : super(key: key);
  @override
  WalletMoneyScreenState createState() => WalletMoneyScreenState();
}

class WalletMoneyScreenState extends State<WalletMoneyScreen> {
  var response;
  String userName;
  String uid;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    getUserName();

    super.initState();
  }

  getUserName() async {
    final userIdd = FirebaseAuth.instance.currentUser.uid;

    var url = "${URL.USER_INFO_URL}/$userIdd.json";
    response = await http.get(Uri.parse(url));
    final responseDataOfUserInfo =
        jsonDecode(response.body) as Map<String, dynamic>;

    userName = responseDataOfUserInfo["name"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;
    String date = DateFormat.yMMMd().format(widget.transactionHistory.date);
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: theme.primaryColor,
           
            centerTitle: true,
            elevation: 0,
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: response != null
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(-0.25, -1),
                        child: Container(
                          width: double.infinity,
                          height: orientation == Orientation.portrait
                              ? height * 0.25
                              : height * 0.3,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.1, -0.6),
                                  child: widget.transactionHistory.coins != null
                                      ? const Text(
                                          'Coins Added',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        )
                                      : const Text(
                                          'Money Added',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.1, -0.1),
                                  child: Text(
                                    '\u{20B9}${widget.addedAmount}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.013,
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(-0.1, 0),
                                  child: Text(
                                    date.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                        child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(-1, -0.65),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          10, 10, 0, 5),
                                      child: Text(
                                        'TRXN ID: ${widget.transactionId}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.9, 0),
                                      child: InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.transactionId));
                                          Fluttertoast.showToast(
                                            msg: "TRXN ID Copied",
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                        },
                                        child: Text(
                                          'COPY',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Added using',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(
                              height: height * .02,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(5, 0, 15, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  widget.transactionHistory.coins != null
                                      ? const Text('Washry Coins',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500))
                                      : const Text('Washry Money',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                  // SizedBox(width: 200,),

                                  Text(
                                    '\u{20B9}${widget.addedAmount}',
                                    style: const TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * .015,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      widget.transactionHistory.transactionRefId == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: height * .01,
                                ),
                                const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 20, 0),
                                  child: Text('Added for',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ),
                                SizedBox(
                                  height: height * .02,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 20, 0),
                                  child: widget.transactionHistory.coins != null
                                      ? Text('Reffer By $userName',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500))
                                      : Text(widget.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                ),
                                SizedBox(
                                  height: height * .01,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 20, 0),
                                  child: Text('Order ID : ${widget.orderId}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey)),
                                ),
                                SizedBox(
                                  height: height * .01,
                                ),
                              ],
                            )
                          : Container(),
                      Container(
                        width: double.infinity,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (ctx) {
                              return SupportScreen(
                                  widget.questions,
                                  widget.answers,
                                  widget.coinQuestions,
                                  widget.coinAnswers);
                            }));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: const BoxDecoration(
                                // color: Color(0xFFEEEEEE),
                                ),
                            child: const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(20, 0, 25, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Need help with this transaction',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text('>',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
