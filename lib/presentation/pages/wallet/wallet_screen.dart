// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/url.dart';
import 'package:washry/application/serviceIds.dart';
import '../../../presentation/pages/wallet/WallteTransaction.dart';
import 'package:http/http.dart' as http;
import '../../../presentation/pages/wallet/AddVoucher.dart';
import '../../../presentation/pages/wallet/supportScreen.dart';

class WalletScreen extends StatefulWidget {
  static const String routeName = 'Wallet-Screen';

  const WalletScreen({Key key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  var supportResponse;
  double washryCoins = 0.0;
  double walletMoney = 0.0;
  List<String> questions = [];
  List<String> coinQuestions = [];
  List<String> answers = [];
  List<String> coinAnswers = [];
  String upiName;
  String upiId;
  String clientId;
  String clientSecret;
  int maxWalletMoney;

  @override
  void didChangeDependencies() {
    final svcId = Provider.of<ServiceIds>(context, listen: true);
    walletMoney = svcId.walletMoney;
    super.didChangeDependencies();
  }

  @override
  initState() {
    getWalletAmount();
    getmaxWalletAmount();
    getCoinsAmount();
    getSupportData();
    super.initState();
  }

  getmaxWalletAmount() async {
    const url = "${URL.APPDATAURL}.json";
    final response = await http.get(Uri.parse(url));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    maxWalletMoney = responseData["maxWalletMoney"];
  }

  getSupportData() async {
    const ur = "${URL.APPDATAURL}/paymentSupport.json";
    final response = await http.get(Uri.parse(ur));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    supportResponse = responseData;

    responseData["walletMoney"].forEach((e) {
      questions.add(e["question"]);
      answers.add(e["answer"]);
    });
    responseData["walletCoins"].forEach((e) {
      coinQuestions.add(e["question"]);
      coinAnswers.add(e["answer"]);
    });
    const url = "${URL.APPDATAURL}.json";
    final responseUpi = await http.get(Uri.parse(url));
    final responseDataUpi =
        jsonDecode(responseUpi.body) as Map<String, dynamic>;
    upiName = responseDataUpi["upi"]["name"];
    upiId = responseDataUpi["upi"]["upiId"];
    clientId = responseDataUpi["upi"]["client-id"];
    clientSecret = responseDataUpi["upi"]["client-secret"];
  }

  @override
  Widget build(BuildContext context) {
    final svcId = Provider.of<ServiceIds>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        body: supportResponse != null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: orientation == Orientation.portrait
                              ? height * .32
                              : height * 0.5,
                          width: width * 2,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                        return SupportScreen(questions, answers,
                                            coinQuestions, coinAnswers);
                                      }));
                                    },
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      padding:
                                          const EdgeInsets.only(right: 22.0),
                                      child: const Text(
                                        "? " "Support",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .04,
                              ),
                              const Text(
                                "Total Wallet Balance",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: Text(
                                  '\u{20B9}' "${svcId.walletMoney}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(children: [
                          SizedBox(
                            height: orientation == Orientation.portrait
                                ? height * .26
                                : height * 0.40,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: SizedBox(
                                      height:
                                          orientation == Orientation.portrait
                                              ? height * .09
                                              : height * 0.20,
                                      width: width * .89,
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.money_off_rounded),
                                              SizedBox(
                                                width: width * .03,
                                              ),
                                              const Text(
                                                "Washry Money",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '\u{20B9}'
                                                "${svcId.walletMoney}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                    height: orientation == Orientation.portrait
                                        ? height * .09
                                        : height * 0.20,
                                    width: width * .89,
                                    child: Card(
                                        child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.money_sharp),
                                          SizedBox(
                                            width: width * .03,
                                          ),
                                          const Text(
                                            "Washry Coins",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(left: 5.0),
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '\u{20B9}' "$washryCoins",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ))),
                                SizedBox(
                                  height: height * .03,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (ctx) {
                                      return WalletTransaction(questions,
                                          answers, coinQuestions, coinAnswers);
                                    }));
                                  },
                                  child: SizedBox(
                                    height: orientation == Orientation.portrait
                                        ? height * .09
                                        : height * 0.20,
                                    width: width * .89,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.money_sharp),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            const Text(
                                              "View all transaction",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 17,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * .35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                //  padding: ,
                                height: orientation == Orientation.portrait
                                    ? height * .06
                                    : height * 0.13,
                                width: width * .4,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (ctx) {
                                      return const AddVoucher();
                                    }));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.black)),
                                  child: const Text(
                                    "Add Voucher",
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: orientation == Orientation.portrait
                                    ? height * .06
                                    : height * 0.13,
                                width: width * .4,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.black)),
                                  child: const Text(
                                    "Add Money",
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: orientation == Orientation.portrait
                                  ? height * .01
                                  : height * 0.07),
                        ])
                      ],
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }

  getCoinsAmount() async {
    final userIdd = FirebaseAuth.instance.currentUser.uid;
    final ur = "${URL.USER_INFO_URL}/$userIdd.json";
    final response = await http.get(Uri.parse(ur));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    washryCoins = await responseData["wallet"].toDouble();
    return washryCoins;
  }

  getWalletAmount() async {
    final userId = FirebaseAuth.instance.currentUser.uid;
    final ur = "${URL.TRANSACTION_URL}/$userId.json";
    final response = await http.get(Uri.parse(ur));
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    walletMoney = responseData["walletMoney"].toDouble() ?? 0.toDouble();
    final svcId = Provider.of<ServiceIds>(context, listen: false);
    svcId.updateWalletMoney(walletMoney);
    return walletMoney;
  }
}
