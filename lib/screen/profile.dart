import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double swidth = size.width;
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      bottomNavigationBar: NavigationBars("Profile"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                "https://img.freepik.com/free-photo/3d-illustration-cute-cartoon-girl-blue-jacket-glasses_1142-41044.jpg",
                height: swidth / 2,
                width: swidth / 2,
                
              ),
            ),
            Text(
              'Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
