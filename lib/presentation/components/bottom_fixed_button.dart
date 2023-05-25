import 'package:flutter/material.dart';

class BottomFixedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BottomFixedButton(
      {@required this.text, @required this.onPressed, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      elevation: 5,
      color: theme.primaryColor,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(text,
              style: theme.textTheme.titleLarge.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}
