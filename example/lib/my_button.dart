import 'package:flutter/material.dart';
import 'package:showcase/showcase.dart';

@Showcased()
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            'Text with custom font.',
            style: TextStyle(fontFamily: 'DancingScript'),
          ),
          Text('Text with custom BOLD font.',
              style: TextStyle(
                fontFamily: 'DancingScript',
                fontWeight: FontWeight.w700,
              )),
          Text('Text with default (Roboto) font.'),
        ],
      );
}
