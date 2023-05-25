import 'package:flutter/material.dart';
import '../../../presentation/pages/wallet/supportPaymentAnswer.dart';

// ignore: must_be_immutable
class SupportPaymentScreen extends StatefulWidget {
  List<String> questions = [];
  List<String> answers = [];
  SupportPaymentScreen(this.questions, this.answers, {Key key}) : super(key: key);
  @override
  SupportPaymentScreenState createState() => SupportPaymentScreenState();
}

class SupportPaymentScreenState extends State<SupportPaymentScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
   
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: true,
       
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: const AlignmentDirectional(-0.25, -1),
              child: Container(
                width: double.infinity,
                height: orientation == Orientation.portrait
                    ? height * 0.15
                    : height * 0.24,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.025,
                    ),
                    Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.fill,
                      width: width * .1,
                      height: orientation == Orientation.portrait
                          ? height * 0.06
                          : height * 0.1,
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
                              fontSize: 30,
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
              child: SingleChildScrollView(
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
                    const Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 20, 0),
                      child: Text(
                        'Payment & Wallets',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: height * .028,
                    ),
                    SizedBox(
                        height: orientation == Orientation.portrait
                            ? height * 0.6
                            : height * 0.4,
                        child: ListView.builder(
                            itemCount: widget.questions.length,
                            itemBuilder: (BuildContext context, int idx) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (ctx) {
                                    return SupportPaymentAnswer(
                                        widget.questions[idx],
                                        widget.answers[idx]);
                                  }));
                                },
                                child: SizedBox(
                                  height: height * .06,
                                  child: Text(
                                    widget.questions[idx],
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
