import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String title;
  final String subtitle;

  const Label(
    this.title,
    this.subtitle, {
    super.key,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16.0)),
          const SizedBox(height: 5.0),
          Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }
}
