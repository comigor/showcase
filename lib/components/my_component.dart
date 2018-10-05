import 'package:flutter/material.dart';

class MyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('This is my text'),
        Text('This is another text'),
        RaisedButton(
          onPressed: () {},
          child: Text('This should be a button'),
          color: Colors.amber,
        ),
        Switch(
          onChanged: (_) {},
          value: true,
        ),
        Slider(
          value: 2.0,
          max: 7.0,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
