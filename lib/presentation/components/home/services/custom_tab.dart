import 'package:flutter/material.dart';

class CountTab extends StatelessWidget {
  final String tabName;
  final int count;

  const CountTab(this.tabName, this.count, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Text(
            tabName,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
