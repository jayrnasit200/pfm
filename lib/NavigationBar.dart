import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:FINEXA/screen/earning.dart';
import 'package:FINEXA/screen/home.dart';
import 'package:FINEXA/screen/profile.dart';
import 'package:FINEXA/screen/spending.dart';

class NavigationBars extends StatefulWidget {
  final String activePage;

  const NavigationBars(this.activePage, {super.key});

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  @override
  Widget build(BuildContext context) {
    // Sync index with the string passed from the screen
    int currentIndex = 0;
    switch (widget.activePage) {
      case 'home':
        currentIndex = 0;
        break;
      case 'Earning':
        currentIndex = 1;
        break;
      case 'Spending':
        currentIndex = 2;
        break;
      case 'Profile':
        currentIndex = 3;
        break;
    }

    final Color primaryBlue = Colors.blue;

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60,
      // Matches your Login/Signup theme
      color: primaryBlue.withOpacity(0.9),
      buttonBackgroundColor: primaryBlue,
      backgroundColor:
          Colors.transparent, // Allows screen content to show behind curves
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: const <Widget>[
        Icon(Icons.home_rounded, size: 30, color: Colors.white),
        Icon(Icons.add_chart_rounded,
            size: 30, color: Colors.white), // Better icon for Earning
        Icon(Icons.payments_rounded,
            size: 30, color: Colors.white), // Better icon for Spending
        Icon(Icons.person_rounded, size: 30, color: Colors.white),
      ],
      onTap: (index) {
        if (index == currentIndex)
          return; // Don't reload if already on the page

        Widget nextScreen;
        switch (index) {
          case 1:
            nextScreen = const EarningScreen();
            break;
          case 2:
            nextScreen = const Spending();
            break;
          case 3:
            nextScreen = const Profile();
            break;
          default:
            nextScreen = const HomeScreen();
        }

        // Use pushReplacement to avoid stacking screens infinitely
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => nextScreen,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
