import 'package:flutter/material.dart';

class PrimaLogo extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;

  const PrimaLogo({
    Key? key,
    required this.height,
    required this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PARTAI',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PRIMA',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 2,
              width: width * 0.8,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: height * 0.05),
            ),
            Text(
              'INDONESIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
