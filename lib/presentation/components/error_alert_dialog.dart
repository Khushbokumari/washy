import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget {
  final Function onPressed;
  final String title;
  final String content;
  final String actionTitle;

  const ErrorAlertDialog({
    Key key,
    @required this.title,
    @required this.onPressed,
    @required this.actionTitle,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: onPressed,
          child: Text(actionTitle),
        ),
      ],
    );
  }
}
