// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class Status extends StatelessWidget {
  final String text;
  final Color color;

  const Status(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("sef");
        checkwater();
        //showNotification();
        //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Settings()));
      },
      child: Container(
        height: 20,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        color: color,
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
