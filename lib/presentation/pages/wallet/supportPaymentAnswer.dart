import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SupportPaymentAnswer extends StatefulWidget {
  String questions;
  String answers;
  SupportPaymentAnswer(this.questions, this.answers, {Key key}) : super(key: key);

  @override
  SupportPaymentAnswerState createState() => SupportPaymentAnswerState();
}

class SupportPaymentAnswerState extends State<SupportPaymentAnswer> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            color: Colors.grey[300],
            // height: height * .06,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                widget.questions.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(
            height: height * .02,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(widget.answers.toString()),
            ),
          )
        ],
      ),
    );
  }
}
