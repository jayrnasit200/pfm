import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';

class earning extends StatefulWidget {
  const earning({super.key});

  @override
  State<earning> createState() => _earningState();
}

class _earningState extends State<earning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      bottomNavigationBar: NavigationBars("earning"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'earning ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
