import 'package:flutter/material.dart';
import '../../../presentation/pages/wallet/supportScreenCoin.dart';
import '../../../presentation/pages/wallet/supportScreenPayment.dart';

// ignore: must_be_immutable
class SupportScreen extends StatefulWidget {
  List<String> questions = [];
  List<String> answers = [];
  List<String> coinQuestions = [];
  List<String> coinAnswers = [];
  SupportScreen(
      this.questions, this.answers, this.coinQuestions, this.coinAnswers, {Key key}) : super(key: key);
  @override
  SupportScreenState createState() => SupportScreenState();
}

class SupportScreenState extends State<SupportScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        actions: const [],
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: const AlignmentDirectional(-0.25, -1),
                child: Container(
                  width: double.infinity,
                  height: orientation == Orientation.portrait
                      ? height * 0.125
                      : height * 0.3,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height * 0.007,
                      ),
                      Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.fill,
                        width: width * .1,
                        height: orientation == Orientation.portrait
                            ? height * 0.05
                            : height * 0.15,
                      ),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 40.0),
                          child: Text(
                            'Support',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: orientation == Orientation.portrait
                          ? height * 0.02
                          : height * 0.05,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return SupportPaymentScreen(
                              widget.questions, widget.answers);
                        }));
                      },
                      child: const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
                        child: Text('Payment & Wallets',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ),
                    ),
                    SizedBox(
                      height: height * .028,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return SupportCoinScreen(
                              widget.coinQuestions, widget.coinAnswers);
                        }));
                      },
                      child: const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
                        child: Text('Washry Coins',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
