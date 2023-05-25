import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../domain/transaction_history.dart';
import '../../../core/network/url.dart';
import '../../../presentation/pages/wallet/walletMoneyScreen.dart';
import '../../../presentation/pages/wallet/walletMoneySubstractScreen.dart';

// ignore: must_be_immutable
class WalletTransaction extends StatefulWidget {
  List<String> questions = [];
  List<String> answers = [];
  List<String> coinQuestions = [];
  List<String> coinAnswers = [];
  WalletTransaction(
      this.questions, this.answers, this.coinQuestions, this.coinAnswers,
      {Key key})
      : super(key: key);
  @override
  WalletTransactionState createState() => WalletTransactionState();
}

class WalletTransactionState extends State<WalletTransaction>
    with SingleTickerProviderStateMixin {
  var responseData;
  TabController _tabController;
  List<TransactionHistory> translist = [];
  List<TransClass> transectionIdsList = [];
  Map<String, List<TransactionHistory>> dateTransMap = {};
  Map<String, List<String>> transectionIdMap = {};
  List<String> dummyDateTime = [];
  List<String> dateTime = [];
  List<String> dummytransactionist = [];
  ScrollController _scrollController;
  bool isLoading = false;
  bool isDataLoaded = false;
  int limit = 0;
  @override
  void initState() {
    paginationFunction();

    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  paginationFunction() async {
    await getDataForAllTransaction();

    setState(() {
      isLoading = false;
    });
    if (limit < dateTime.length) {
      for (var i = 0; i < limit; i++) {
        dummytransactionist.add(dateTime[i]);
      }
    }
    scrollController();
  }

  void scrollController() {
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          isLoading = true;
        });

        Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
              if (limit + 10 <= dateTime.length) {
                log('hello world');
                limit += 10;
              } else {
                log('hello world12');
                limit = dateTime.length;
              }
              isLoading = false;

              if (limit < dateTime.length) {
                dummytransactionist = [];
                for (var i = 0; i < limit; i++) {
                  dummytransactionist.add(dateTime[i]);
                }
              }
            }));
      }
    });
  }

  getDataForAllTransaction() async {
    final userId = FirebaseAuth.instance.currentUser.uid;
    final transUrl = "${URL.TRANSACTION_URL}/$userId/transHistory.json";
    final result = await http.get(Uri.parse(transUrl));
    responseData = jsonDecode(result.body) as Map<String, dynamic>;
    setState(() {
      isDataLoaded = true;
    });
    responseData.forEach((key, value) {
      TransClass transClass = TransClass();
      transClass.date = DateTime.parse(value["date"]);
      transClass.transactionId = key;
      TransactionHistory transactionHistory = TransactionHistory();
      transactionHistory.amount = value["amount"];
      transactionHistory.date = DateTime.parse(value["date"]);
      transactionHistory.coins = value["coins"];
      transactionHistory.transactionRefId = value["transactionRefId"];
      transactionHistory.credit = value['credit'];
      transactionHistory.title = value['title'];
      log('cre ${value['credit']}');
      try {
        Map<String, dynamic> val = value as Map<String, dynamic>;
        if (val.containsKey("orderId")) {
          transactionHistory.orderId = value["orderId"];
        }
      } catch (e) {
        log(e.toString());
      }
      translist.add(transactionHistory);
      transectionIdsList.add(transClass);

      // translist=translist.reversed;
    });

    translist.sort((TransactionHistory a, TransactionHistory b) =>
        b.date.compareTo(a.date));
    transectionIdsList
        .sort((TransClass a, TransClass b) => b.date.compareTo(a.date));
    for (var element in translist) {
      String date = DateFormat.yMMMd().format(element.date);

      if (dateTransMap.containsKey(date)) {
        dateTransMap[date].add(element);
      } else {
        dateTransMap[date] = [];
        dateTransMap[date].add(element);
      }
    }

    for (var element in transectionIdsList) {
      String date = DateFormat.yMMMd().format(element.date);
      if (transectionIdMap.containsKey(date)) {
        transectionIdMap[date].add(element.transactionId);
      } else {
        transectionIdMap[date] = [];
        transectionIdMap[date].add(element.transactionId);
      }
    }
    dateTime = dateTransMap.keys.toList();
    for (int i = 0; i < dateTime.length; i++) {
      if (i < 5) {
        limit++;
        dummyDateTime.add(dateTime[i]);
      } else {
        break;
      }
    }
    log("ashu");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            tabBarTheme: const TabBarTheme(), primarySwatch: Colors.deepOrange),
        home: WillPopScope(
          onWillPop: _onWillPop,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                  iconTheme: const IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  title: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        ' Wallet Transaction',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        child: Text(
                          'All',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Money',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Coins',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(controller: _tabController, children: <Widget>[
                  getAllTransaction(),
                  getMoneyTransaction(),
                  getCoinsTransaction()
                ])),
          ),
        ));
  }

  Future<bool> _onWillPop() async {
    if (_tabController.index == 0) {
      await SystemNavigator.pop();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      _tabController.index = 0;
    });

    return _tabController.index == 0;
  }

  getAllTransaction() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    String date = "amit";
    log('limit $limit');
    // log(responseData.toString());
    return !isDataLoaded
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : responseData != null
            ? ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: responseData != null ? limit : 0,
                itemBuilder: (BuildContext context, int index) {
                  if (index == limit - 1 && index != dateTime.length - 1) {
                    log('123');
                    return Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dateTransMap[dateTime[index]].length,
                            itemBuilder: (BuildContext context, int idx) {
                              if (idx == 0) {
                                return Column(
                                  children: [
                                    Container(
                                      color: Colors.grey[200],
                                      width: width * double.infinity,
                                      height: height * 0.05,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 25, top: 13),
                                          child: Text(
                                            dateTime[index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[400]),
                                          )),
                                    ),
                                    SizedBox(height: height * 0.01),
                                    GestureDetector(
                                      onTap: () {
                                        (dateTransMap[dateTime[index]][idx]
                                                    .credit ==
                                                true)
                                            ? Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) {
                                                return WalletMoneyScreen(
                                                  dateTransMap[
                                                      dateTime[index]][idx],
                                                  transectionIdMap[
                                                      dateTime[index]][idx],
                                                  dateTransMap[
                                                              dateTime[index]]
                                                          [idx]
                                                      .amount,
                                                  widget.questions,
                                                  widget.answers,
                                                  widget.coinQuestions,
                                                  widget.coinAnswers,
                                                  dateTransMap[
                                                              dateTime[index]]
                                                          [idx]
                                                      .title,
                                                  dateTransMap[
                                                              dateTime[index]]
                                                          [idx]
                                                      .orderId,
                                                );
                                              }))
                                            : Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) {
                                                return WalletMoneySubstractScreen(
                                                    dateTransMap[
                                                        dateTime[index]][idx],
                                                    transectionIdMap[
                                                        dateTime[index]][idx],
                                                    widget.questions,
                                                    widget.answers,
                                                    widget.coinQuestions,
                                                    widget.coinAnswers);
                                              }));
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    (dateTransMap[dateTime[
                                                                        index]]
                                                                    [idx]
                                                                .orderId !=
                                                            null)
                                                        ? dateTransMap[dateTime[index]]
                                                                        [idx]
                                                                    .coins ==
                                                                null
                                                            ? dateTransMap[dateTime[index]][
                                                                            idx]
                                                                        .credit ==
                                                                    true
                                                                ? const Text(
                                                                    'Refunded ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : const Text(
                                                                    'Order Completed',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                            : dateTransMap[dateTime[index]]
                                                                            [
                                                                            idx]
                                                                        .orderId !=
                                                                    null
                                                                ? dateTransMap[dateTime[index]][idx]
                                                                            .credit ==
                                                                        true
                                                                    ? const Text(
                                                                        'Refunded ',
                                                                        style:
                                                                            TextStyle(fontWeight: FontWeight.bold),
                                                                      )
                                                                    : const Text(
                                                                        'Order Completed ',
                                                                        style:
                                                                            TextStyle(fontWeight: FontWeight.bold),
                                                                      )
                                                                : const Text(
                                                                    'Referral bonus earned',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                        : const Text(
                                                            'Wallet recharge',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                    // (dateTransMap[dateTime[index]]
                                                    //                 [idx]
                                                    //             .orderId !=
                                                    //         null)
                                                    //     ? SizedBox(
                                                    //         width: width * .4,
                                                    //       )
                                                    //     : SizedBox(
                                                    //         width: width * .43,
                                                    //       ),
                                                    // dateTransMap[dateTime[index]]
                                                    //                     [idx]
                                                    //                 .credit ==
                                                    //             true &&
                                                    //         dateTransMap[dateTime[
                                                    //                         index]]
                                                    //                     [idx]
                                                    //                 .orderId !=
                                                    //             null
                                                    //     ? SizedBox(
                                                    //         width: width * .1,
                                                    //       )
                                                    //     : SizedBox(),
                                                    const Spacer(),
                                                    dateTransMap[dateTime[
                                                                        index]]
                                                                    [idx]
                                                                .credit ==
                                                            false
                                                        ? Text(
                                                            "-" '\u{20B9}' +
                                                                translist[
                                                                        index]
                                                                    .amount
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )
                                                        : Text(
                                                            "+" '\u{20B9}' +
                                                                translist[
                                                                        index]
                                                                    .amount
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )
                                                  ],
                                                ),
                                                // Row(
                                                //   children: [
                                                //     Text(dateTransMap[dateTime[
                                                //                 index]][idx]
                                                //             .orderId ??
                                                //         "Add to Wallet"),
                                                //   ],
                                                // ),
                                                // dateTransMap[dateTime[index]][idx]
                                                //             .coins !=
                                                //         null
                                                //     ? Row(children: [
                                                //         Text("Total Coins - " +
                                                //                 dateTransMap[dateTime[
                                                //                             index]]
                                                //                         [idx]
                                                //                     .coins
                                                //                     .toString() ??
                                                //             "")
                                                //       ])
                                                //     : Container(),
                                              ],
                                            ),
                                            // subtitle: Text(translist[index].date),
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              }
                              return GestureDetector(
                                onTap: () {
                                  (dateTransMap[dateTime[index]][idx].credit ==
                                          true)
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                          return WalletMoneyScreen(
                                            dateTransMap[dateTime[index]][idx],
                                            transectionIdMap[dateTime[index]]
                                                [idx],
                                            dateTransMap[dateTime[index]][idx]
                                                .amount,
                                            widget.questions,
                                            widget.answers,
                                            widget.coinQuestions,
                                            widget.coinAnswers,
                                            dateTransMap[dateTime[index]][idx]
                                                .title,
                                            dateTransMap[dateTime[index]][idx]
                                                .orderId,
                                          );
                                        }))
                                      : Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                          return WalletMoneySubstractScreen(
                                              dateTransMap[dateTime[index]]
                                                  [idx],
                                              transectionIdMap[dateTime[index]]
                                                  [idx],
                                              widget.questions,
                                              widget.answers,
                                              widget.coinQuestions,
                                              widget.coinAnswers);
                                        }));
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Column(
                                        children: [
                                          Row(
                                            children: [
                                              (dateTransMap[dateTime[index]][idx]
                                                          .orderId !=
                                                      null)
                                                  ? dateTransMap[dateTime[index]]
                                                                  [idx]
                                                              .coins ==
                                                          null
                                                      ? dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .credit ==
                                                              true
                                                          ? const Text(
                                                              'Refunded ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          : const Text(
                                                              'Order Completed ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                      : dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .orderId !=
                                                              null
                                                          ? dateTransMap[dateTime[index]]
                                                                          [idx]
                                                                      .credit ==
                                                                  true
                                                              ? const Text(
                                                                  'Refunded ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              : const Text(
                                                                  'Order Completed ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                          : const Text(
                                                              'Referral bonus earned',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                  : const Text(
                                                      'Wallet recharge',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                              // (dateTransMap[dateTime[index]][idx]
                                              //             .orderId !=
                                              //         null)
                                              //     ? SizedBox(
                                              //         width: width * .4,
                                              //       )
                                              //     : SizedBox(
                                              //         width: width * .43,
                                              //       ),
                                              // dateTransMap[dateTime[index]][idx]
                                              //                 .credit ==
                                              //             true &&
                                              //         dateTransMap[dateTime[index]]
                                              //                     [idx]
                                              //                 .orderId !=
                                              //             null
                                              //     ? SizedBox(
                                              //         width: width * .1,
                                              //       )
                                              //     : SizedBox(),
                                              const Spacer(),
                                              (dateTransMap[dateTime[index]]
                                                              [idx]
                                                          .credit ==
                                                      false)
                                                  ? Text(
                                                      "-" '\u{20B9}' +
                                                          dateTransMap[dateTime[
                                                                  index]][idx]
                                                              .amount
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  : Text(
                                                      "+" '\u{20B9}' +
                                                          dateTransMap[dateTime[
                                                                  index]][idx]
                                                              .amount
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                            ],
                                          ),
                                          // Row(
                                          //   children: [
                                          //     Text(dateTransMap[dateTime[index]]
                                          //                 [idx]
                                          //             .orderId ??
                                          //         "Add to Wallet"),
                                          //   ],
                                          // ),
                                          // dateTransMap[dateTime[index]][idx]
                                          //             .coins !=
                                          //         null
                                          //     ? Row(children: [
                                          //         Text("Total Coins - " +
                                          //                 dateTransMap[dateTime[
                                          //                         index]][idx]
                                          //                     .coins
                                          //                     .toString() ??
                                          //             "")
                                          //       ])
                                          //     : Container(),
                                        ],
                                      ),
                                      // subtitle: Text(translist[index].date),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            }),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                  log('index $index');
                  log(date.toString());
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dateTransMap[dateTime[index]].length,
                      itemBuilder: (BuildContext context, int idx) {
                        if (idx == 0) {
                          return Column(
                            children: [
                              Container(
                                color: Colors.grey[200],
                                width: width * double.infinity,
                                height: height * 0.05,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, top: 13),
                                    child: Text(
                                      dateTime[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[400]),
                                    )),
                              ),
                              SizedBox(height: height * 0.01),
                              GestureDetector(
                                onTap: () {
                                  (dateTransMap[dateTime[index]][idx]
                                              .credit ==
                                          true)
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                          return WalletMoneyScreen(
                                            dateTransMap[dateTime[index]]
                                                [idx],
                                            transectionIdMap[dateTime[index]]
                                                [idx],
                                            dateTransMap[dateTime[index]][idx]
                                                .amount,
                                            widget.questions,
                                            widget.answers,
                                            widget.coinQuestions,
                                            widget.coinAnswers,
                                            dateTransMap[dateTime[index]][idx]
                                                .title,
                                            dateTransMap[dateTime[index]][idx]
                                                .orderId,
                                          );
                                        }))
                                      : Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                          return WalletMoneySubstractScreen(
                                              dateTransMap[dateTime[index]]
                                                  [idx],
                                              transectionIdMap[
                                                  dateTime[index]][idx],
                                              widget.questions,
                                              widget.answers,
                                              widget.coinQuestions,
                                              widget.coinAnswers);
                                        }));
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Column(
                                        children: [
                                          Row(
                                            children: [
                                              (dateTransMap[dateTime[index]]
                                                              [idx]
                                                          .orderId !=
                                                      null)
                                                  ? dateTransMap[dateTime[index]]
                                                                  [idx]
                                                              .coins ==
                                                          null
                                                      ? dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .credit ==
                                                              true
                                                          ? const Text(
                                                              'Refunded ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          : const Text(
                                                              'Order Completed ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                      : dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .orderId !=
                                                              null
                                                          ? dateTransMap[dateTime[index]]
                                                                          [idx]
                                                                      .credit ==
                                                                  true
                                                              ? const Text(
                                                                  'Refunded ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight.bold),
                                                                )
                                                              : const Text(
                                                                  'Order Completed ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight.bold),
                                                                )
                                                          : const Text(
                                                              'Referral bonus earned',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                  : const Text(
                                                      'Wallet recharge',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                    ),
                                              // (dateTransMap[dateTime[index]][idx]
                                              //             .orderId !=
                                              //         null)
                                              //     ? SizedBox(
                                              //         width: width * .4,
                                              //       )
                                              //     : SizedBox(
                                              //         width: width * .43,
                                              //       ),
                                              // dateTransMap[dateTime[index]][idx]
                                              //                 .credit ==
                                              //             true &&
                                              //         dateTransMap[dateTime[
                                              //                     index]][idx]
                                              //                 .orderId !=
                                              //             null
                                              //     ? SizedBox(
                                              //         width: width * .1,
                                              //       )
                                              //     : SizedBox(),
                                              const Spacer(),
                                              dateTransMap[dateTime[index]]
                                                              [idx]
                                                          .credit ==
                                                      false
                                                  ?
                                                  //  Text(
                                                  //     "-" +
                                                  //         '\u{20B9}' +
                                                  //         translist[index]
                                                  //             .amount
                                                  //             .toString(),
                                                  //     style: TextStyle(
                                                  //         color: Colors.red,
                                                  //         fontWeight:
                                                  //             FontWeight.w500),
                                                  //   )

                                                  Text(
                                                      "-" '\u{20B9}' +
                                                          dateTransMap[dateTime[
                                                                  index]][idx]
                                                              .amount
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                    )
                                                  : Text(
                                                      "+" '\u{20B9}' +
                                                          translist[index]
                                                              .amount
                                                              .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                    )
                                            ],
                                          ),
                                          // Row(
                                          //   children: [
                                          //     Text(dateTransMap[dateTime[index]]
                                          //                 [idx]
                                          //             .orderId ??
                                          //         "Add to Wallet"),
                                          //   ],
                                          // ),
                                          // dateTransMap[dateTime[index]][idx]
                                          //             .coins !=
                                          //         null
                                          //     ? Row(children: [
                                          //         Text("Total Coins - " +
                                          //                 dateTransMap[dateTime[
                                          //                         index]][idx]
                                          //                     .coins
                                          //                     .toString() ??
                                          //             "")
                                          //       ])
                                          //     : Container(),
                                        ],
                                      ),
                                      // subtitle: Text(translist[index].date),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            (dateTransMap[dateTime[index]][idx].credit == true)
                                ? Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                    return WalletMoneyScreen(
                                      dateTransMap[dateTime[index]][idx],
                                      transectionIdMap[dateTime[index]][idx],
                                      dateTransMap[dateTime[index]][idx].amount,
                                      widget.questions,
                                      widget.answers,
                                      widget.coinQuestions,
                                      widget.coinAnswers,
                                      dateTransMap[dateTime[index]][idx].title,
                                      dateTransMap[dateTime[index]][idx]
                                          .orderId,
                                    );
                                  }))
                                : Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                    return WalletMoneySubstractScreen(
                                        dateTransMap[dateTime[index]][idx],
                                        transectionIdMap[dateTime[index]][idx],
                                        widget.questions,
                                        widget.answers,
                                        widget.coinQuestions,
                                        widget.coinAnswers);
                                  }));
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Column(
                                  children: [
                                    Row(
                                      children: [
                                        (dateTransMap[dateTime[index]][idx]
                                                    .orderId !=
                                                null)
                                            ? dateTransMap[dateTime[index]][idx]
                                                        .coins ==
                                                    null
                                                ? dateTransMap[dateTime[index]]
                                                                [idx]
                                                            .credit ==
                                                        true
                                                    ? const Text(
                                                        'Refunded ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    : const Text(
                                                        'Order Completed ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                : dateTransMap[dateTime[index]]
                                                                [idx]
                                                            .orderId !=
                                                        null
                                                    ? dateTransMap[dateTime[
                                                                    index]][idx]
                                                                .credit ==
                                                            true
                                                        ? const Text(
                                                            'Refunded ',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        : const Text(
                                                            'Order Completed ',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                    : const Text(
                                                        'Referral bonus earned',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                            : const Text(
                                                'Wallet recharge',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                        // (dateTransMap[dateTime[index]][idx]
                                        //             .orderId !=
                                        //         null)
                                        //     ? SizedBox(
                                        //         width: width * .4,
                                        //       )
                                        //     : SizedBox(
                                        //         width: width * .43,
                                        //       ),
                                        // dateTransMap[dateTime[index]][idx].credit ==
                                        //             true &&
                                        //         dateTransMap[dateTime[index]][idx]
                                        //                 .orderId !=
                                        //             null
                                        //     ? SizedBox(
                                        //         width: width * .1,
                                        //       )
                                        //     : SizedBox(),
                                        const Spacer(),
                                        dateTransMap[dateTime[index]][idx]
                                                    .credit ==
                                                false
                                            ? Text(
                                                "-" '\u{20B9}' +
                                                    dateTransMap[
                                                                dateTime[index]]
                                                            [idx]
                                                        .amount
                                                        .toString(),
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            : Text(
                                                "+" '\u{20B9}' +
                                                    dateTransMap[
                                                                dateTime[index]]
                                                            [idx]
                                                        .amount
                                                        .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(dateTransMap[dateTime[index]][idx]
                                    //             .orderId ??
                                    //         "Add to Wallet"),
                                    //   ],
                                    // ),
                                    // dateTransMap[dateTime[index]][idx].coins != null
                                    //     ? Row(children: [
                                    //         Text("Total Coins - " +
                                    //                 dateTransMap[dateTime[index]]
                                    //                         [idx]
                                    //                     .coins
                                    //                     .toString() ??
                                    //             "")
                                    //       ])
                                    //     : Container(),
                                  ],
                                ),
                                // subtitle: Text(translist[index].date),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      });
                },
              )
            : const Center(
                child: Center(
                child: Text(
                  "No transaction",
                  style: TextStyle(fontSize: 18),
                ),
              ));
  }

  getMoneyTransaction() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    log('date time${dateTime.length}');

    return !isDataLoaded
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : responseData != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: responseData != null ? dateTime.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  bool isTrue = false;
                  for (var element in dateTransMap[dateTime[index]]) {
                    if (element.coins == null) {
                      isTrue = true;
                    }
                  }
                  return isTrue
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dateTransMap[dateTime[index]].length,
                          itemBuilder: (BuildContext context, int idx) {
                            log("message");
                            if (idx == 0) {
                              return Column(
                                children: [
                                  Container(
                                    color: Colors.grey[200],
                                    width: width * double.infinity,
                                    height: height * 0.05,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, top: 13),
                                        child: Text(
                                          dateTime[index],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[400]),
                                        )),
                                  ),
                                  dateTransMap[dateTime[index]][idx].coins ==
                                          null
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) {
                                              return (dateTransMap[
                                                                  dateTime[index]]
                                                              [idx]
                                                          .credit ==
                                                      true)
                                                  ? WalletMoneyScreen(
                                                      dateTransMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      transectionIdMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      dateTransMap[dateTime[
                                                              index]][idx]
                                                          .amount,
                                                      widget.questions,
                                                      widget.answers,
                                                      widget.coinQuestions,
                                                      widget.coinAnswers,
                                                      dateTransMap[dateTime[
                                                              index]][idx]
                                                          .title,
                                                      dateTransMap[dateTime[
                                                              index]][idx]
                                                          .orderId,
                                                    )
                                                  : WalletMoneySubstractScreen(
                                                      dateTransMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      transectionIdMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      widget.questions,
                                                      widget.answers,
                                                      widget.coinQuestions,
                                                      widget.coinAnswers);
                                            }));
                                          },
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        (dateTransMap[dateTime[
                                                                            index]]
                                                                        [idx]
                                                                    .orderId !=
                                                                null)
                                                            ? dateTransMap[dateTime[index]]
                                                                            [
                                                                            idx]
                                                                        .credit ==
                                                                    true
                                                                ? const Text(
                                                                    'Refunded ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : const Text(
                                                                    'Order Completed ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                            : const Text(
                                                                'Wallet recharge',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                        // (dateTransMap[dateTime[
                                                        //                     index]]
                                                        //                 [idx]
                                                        //             .orderId !=
                                                        //         null)
                                                        //     ? SizedBox(
                                                        //         width: width * .4,
                                                        //       )
                                                        //     : SizedBox(
                                                        //         width:
                                                        //             width * .43,
                                                        //       ),
                                                        const Spacer(),
                                                        // dateTransMap[dateTime[index]]
                                                        //                     [idx]
                                                        //                 .credit ==
                                                        //             true &&
                                                        //         dateTransMap[dateTime[
                                                        //                         index]]
                                                        //                     [idx]
                                                        //                 .orderId !=
                                                        //             null
                                                        //     ? SizedBox(
                                                        //         width: width * .1,
                                                        //       )
                                                        //     : SizedBox(),
                                                        (dateTransMap[dateTime[
                                                                            index]]
                                                                        [idx]
                                                                    .credit !=
                                                                true)
                                                            ? Text(
                                                                "-" '\u{20B9}' +
                                                                    translist[
                                                                            index]
                                                                        .amount
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )
                                                            : Text(
                                                                "+" '\u{20B9}' +
                                                                    translist[
                                                                            index]
                                                                        .amount
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )
                                                      ],
                                                    ),
                                                    // Row(
                                                    //   children: [
                                                    //     Text(dateTransMap[dateTime[
                                                    //                 index]][idx]
                                                    //             .orderId ??
                                                    //         "Add to Wallet"),
                                                    //   ],
                                                    // ),
                                                    // dateTransMap[dateTime[index]]
                                                    //                 [idx]
                                                    //             .coins !=
                                                    //         null
                                                    //     ? Row(children: [
                                                    //         Text("Total Coins - " +
                                                    //                 dateTransMap[dateTime[
                                                    //                             index]]
                                                    //                         [idx]
                                                    //                     .coins
                                                    //                     .toString() ??
                                                    //             "")
                                                    //       ])
                                                    // : Container(),
                                                  ],
                                                ),
                                                // subtitle: Text(translist[index].date),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              );
                            }
                            return dateTransMap[dateTime[index]][idx].coins ==
                                    null
                                ? GestureDetector(
                                    onTap: () {
                                      (dateTransMap[dateTime[index]][idx]
                                                  .credit ==
                                              true)
                                          ? Navigator.of(context).push(
                                              MaterialPageRoute(builder: (ctx) {
                                              return WalletMoneyScreen(
                                                dateTransMap[dateTime[index]]
                                                    [idx],
                                                transectionIdMap[
                                                    dateTime[index]][idx],
                                                dateTransMap[dateTime[index]]
                                                        [idx]
                                                    .amount,
                                                widget.questions,
                                                widget.answers,
                                                widget.coinQuestions,
                                                widget.coinAnswers,
                                                dateTransMap[dateTime[index]]
                                                        [idx]
                                                    .title,
                                                dateTransMap[dateTime[index]]
                                                        [idx]
                                                    .orderId,
                                              );
                                            }))
                                          : Navigator.of(context).push(
                                              MaterialPageRoute(builder: (ctx) {
                                              return WalletMoneySubstractScreen(
                                                  dateTransMap[dateTime[index]]
                                                      [idx],
                                                  transectionIdMap[
                                                      dateTime[index]][idx],
                                                  widget.questions,
                                                  widget.answers,
                                                  widget.coinQuestions,
                                                  widget.coinAnswers);
                                            }));
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  (dateTransMap[dateTime[index]]
                                                                  [idx]
                                                              .orderId !=
                                                          null)
                                                      ? dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .credit ==
                                                              true
                                                          ? const Text(
                                                              'Refunded ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          : const Text(
                                                              'Order Completed ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                      : const Text(
                                                          'Wallet recharge',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                  (dateTransMap[dateTime[index]]
                                                                  [idx]
                                                              .orderId !=
                                                          null)
                                                      ? SizedBox(
                                                          width: width * .4,
                                                        )
                                                      : SizedBox(
                                                          width: width * .43,
                                                        ),
                                                  // dateTransMap[dateTime[index]][idx]
                                                  //                 .credit ==
                                                  //             true &&
                                                  //         dateTransMap[dateTime[
                                                  //                     index]][idx]
                                                  //                 .orderId !=
                                                  //             null
                                                  //     ? SizedBox(
                                                  //         width: width * .1,
                                                  //       )
                                                  //     : SizedBox(),
                                                  const Spacer(),
                                                  (dateTransMap[dateTime[index]]
                                                                  [idx]
                                                              .credit !=
                                                          true)
                                                      ? Text(
                                                          "-" '\u{20B9}' +
                                                              dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .amount
                                                                  .toString(),
                                                          style: const TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      : Text(
                                                          "+" '\u{20B9}' +
                                                              dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .amount
                                                                  .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                ],
                                              ),
                                              // Row(
                                              //   children: [
                                              //     Text(dateTransMap[dateTime[index]]
                                              //                 [idx]
                                              //             .orderId ??
                                              //         "Add to Wallet"),
                                              //   ],
                                              // ),
                                              dateTransMap[dateTime[index]][idx]
                                                          .coins !=
                                                      null
                                                  ? Row(children: [
                                                      Text(
                                                          "Total Coins - ${dateTransMap[dateTime[index]][idx].coins}" ??
                                                              "")
                                                    ])
                                                  : Container(),
                                            ],
                                          ),
                                          // subtitle: Text(translist[index].date),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  )
                                : Container();
                          })
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: const Center(
                            child: Text(
                              "No transaction",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                },
              )
            : const Center(
                child: Center(
                child: Text(
                  "No transaction",
                  style: TextStyle(fontSize: 18),
                ),
              ));
  }

  getCoinsTransaction() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return !isDataLoaded
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : responseData != null
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: responseData != null ? dateTime.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  bool isTrue = false;
                  for (var element in dateTransMap[dateTime[index]]) {
                    isTrue = true;
                  }
                  return isTrue
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dateTransMap[dateTime[index]].length,
                          itemBuilder: (BuildContext context, int idx) {
                            log("message");
                            if (idx == 0) {
                              return Column(
                                children: [
                                  Container(
                                    color: Colors.grey[200],
                                    width: width * double.infinity,
                                    height: height * 0.05,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, top: 13),
                                        child: Text(
                                          dateTime[index],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[400]),
                                        )),
                                  ),
                                  dateTransMap[dateTime[index]][idx].coins !=
                                          null
                                      ? GestureDetector(
                                          onTap: () {
                                            (dateTransMap[dateTime[index]]
                                                            [idx]
                                                        .orderId ==
                                                    null)
                                                ? Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (ctx) {
                                                    return WalletMoneyScreen(
                                                      dateTransMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      transectionIdMap[
                                                              dateTime[index]]
                                                          [idx],
                                                      translist[index].amount,
                                                      widget.questions,
                                                      widget.answers,
                                                      widget.coinQuestions,
                                                      widget.coinAnswers,
                                                      dateTransMap[dateTime[
                                                              index]][idx]
                                                          .title,
                                                      dateTransMap[dateTime[
                                                              index]][idx]
                                                          .orderId,
                                                    );
                                                  }))
                                                : Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (ctx) {
                                                    return WalletMoneySubstractScreen(
                                                        dateTransMap[dateTime[
                                                            index]][idx],
                                                        transectionIdMap[
                                                            dateTime[
                                                                index]][idx],
                                                        widget.questions,
                                                        widget.answers,
                                                        widget.coinQuestions,
                                                        widget.coinAnswers);
                                                  }));
                                          },
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Column(
                                                  children: [
                                                    Row(children: [
                                                      (dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .orderId !=
                                                              null)
                                                          ? const Text(
                                                              'Order Completed',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                          : const Text(
                                                              'Referral bonus earned',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                      // (dateTransMap[dateTime[
                                                      //                 index]][idx]
                                                      //             .orderId !=
                                                      //         null)
                                                      //     ? SizedBox(
                                                      //         width: width * .4,
                                                      //       )
                                                      //     : SizedBox(
                                                      //         width: width * .37,
                                                      //       ),
                                                      const Spacer(),
                                                      (dateTransMap[dateTime[
                                                                          index]]
                                                                      [idx]
                                                                  .orderId !=
                                                              null)
                                                          ? Text(
                                                              "-" '\u{20B9}' +
                                                                  dateTransMap[dateTime[index]]
                                                                          [
                                                                          idx]
                                                                      .amount
                                                                      .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                          : Text(
                                                              "+" '\u{20B9}' +
                                                                  dateTransMap[dateTime[index]]
                                                                          [
                                                                          idx]
                                                                      .amount
                                                                      .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )
                                                    ]),
                                                    // Row(children: [
                                                    //   Text(translist[index]
                                                    //           .orderId ??
                                                    //       "")
                                                    // ]),
                                                  ],
                                                ),
                                                // subtitle: Text(translist[index].date),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              );
                            }
                            return dateTransMap[dateTime[index]][idx].coins !=
                                    null
                                ? GestureDetector(
                                    onTap: () {
                                      (dateTransMap[dateTime[index]][idx]
                                                  .orderId ==
                                              null)
                                          ? Navigator.of(context).push(
                                              MaterialPageRoute(builder: (ctx) {
                                              return WalletMoneyScreen(
                                                dateTransMap[dateTime[index]]
                                                    [idx],
                                                transectionIdMap[
                                                    dateTime[index]][idx],
                                                translist[index].amount,
                                                widget.questions,
                                                widget.answers,
                                                widget.coinQuestions,
                                                widget.coinAnswers,
                                                dateTransMap[dateTime[index]]
                                                        [idx]
                                                    .title,
                                                dateTransMap[dateTime[index]]
                                                        [idx]
                                                    .orderId,
                                              );
                                            }))
                                          : Navigator.of(context).push(
                                              MaterialPageRoute(builder: (ctx) {
                                              return WalletMoneySubstractScreen(
                                                  dateTransMap[dateTime[index]]
                                                      [idx],
                                                  transectionIdMap[
                                                      dateTime[index]][idx],
                                                  widget.questions,
                                                  widget.answers,
                                                  widget.coinQuestions,
                                                  widget.coinAnswers);
                                            }));
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Column(
                                            children: [
                                              Row(children: [
                                                (dateTransMap[dateTime[index]]
                                                                [idx]
                                                            .orderId !=
                                                        null)
                                                    ? const Text(
                                                        'Order Completed',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    : const Text(
                                                        'Referral bonus earned',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                const Spacer(),
                                                // (dateTransMap[dateTime[index]][idx]
                                                //             .orderId !=
                                                //         null)
                                                //     ? SizedBox(
                                                //         width: width * .4,
                                                //       )
                                                //     : SizedBox(
                                                //         width: width * .37,
                                                //       ),
                                                (dateTransMap[dateTime[index]]
                                                                [idx]
                                                            .orderId !=
                                                        null)
                                                    ? Text(
                                                        "-" '\u{20B9}' +
                                                            dateTransMap[dateTime[
                                                                    index]][idx]
                                                                .amount
                                                                .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                                    : Text(
                                                        "+" '\u{20B9}' +
                                                            dateTransMap[dateTime[
                                                                    index]][idx]
                                                                .amount
                                                                .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )
                                              ]),
                                              // Row(children: [
                                              //   Text(dateTransMap[dateTime[index]]
                                              //               [idx]
                                              //           .orderId ??
                                              //       "")
                                              // ]),
                                            ],
                                          ),
                                          // subtitle: Text(translist[index].date),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  )
                                : Container();
                          })
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: const Center(
                            child: Text(
                              "No transaction",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                },
              )

            // ListView.builder(
            //     reverse: true,
            //     itemCount: responseData != null ? responseData.length : 0,
            //     itemBuilder: (BuildContext context, int index) {
            //       log(translist[index].coins.toString());
            //       return translist[index].coins != null
            //           ? GestureDetector(
            //               child: Column(
            //                 children: [
            //                   ListTile(
            //                     title: Column(
            //                       children: [
            //                         Row(children: [
            //                           Text('Received from washry',
            //                               style: TextStyle(
            //                                   fontWeight: FontWeight.bold)),
            //                           SizedBox(
            //                             width: width * .35,
            //                           ),
            //                           Text('\u{20B9}' +
            //                               translist[index].amount.toString()),
            //                         ]),
            //                         Row(children: [
            //                           Text(translist[index].orderId ?? "")
            //                         ]),

            //                       ],
            //                     ),
            //                     // subtitle: Text(translist[index].date),
            //                   ),
            //                   Divider(),
            //                 ],
            //               ),
            //             )
            //           : Container();
            //     },
            //   )
            : const Center(
                child: Text(
                  "No transaction",
                  style: TextStyle(fontSize: 18),
                ),
              );
  }
}

class TransClass {
  DateTime date;
  String transactionId;
}
