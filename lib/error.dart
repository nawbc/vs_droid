import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ErrorBoard extends StatelessWidget {
  const ErrorBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              UniconsLine.exclamation_triangle,
              color: Colors.red,
              size: 50,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Something wrong',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
