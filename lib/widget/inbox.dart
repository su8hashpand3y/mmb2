import 'package:flutter/material.dart';

class Inbox extends StatelessWidget {
  Inbox({
    Key key,
    @required String info,
    @required this.context,
  })  : info = info,
        super(key: key);

  final String info;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'This is your inbox',
          ),
          Text(
            info,
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}
