import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pfm/screen/earning.dart';
import 'package:pfm/screen/home.dart';
import 'package:pfm/screen/profile.dart';
import 'package:pfm/screen/spending.dart';

class NavigationBars extends StatefulWidget {
  final String s; // Declare a member variable to hold the string value.

  const NavigationBars(this.s, {super.key});

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    if (widget.s == 'home') {
      _currentIndex = 0;
    } else if (widget.s == 'earning') {
      _currentIndex = 1;
    } else if (widget.s == 'Spending') {
      _currentIndex = 2;
    } else if (widget.s == 'Profile') {
      _currentIndex = 3;
    }

    return CurvedNavigationBar(
      index: _currentIndex,
      color: Colors.blue,
      backgroundColor: Colors.white,
      items: <Widget>[
        Icon(
          Icons.home,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.arrow_downward,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.arrow_upward,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.person,
          size: 30,
          color: Colors.white,
        ),
      ],
      onTap: (index) {
        //Handle button tap
        setState(() {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const earning()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Spending()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const homescreen()),
            );
          }
        });
      },
    );
  }
}
