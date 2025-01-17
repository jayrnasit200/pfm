import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBars("home"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDoctorCard(),
              const SizedBox(height: 20),
              _buildHealthStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.search, size: 30, color: Colors.grey.shade800),
        Text(
          'Medicalic',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        CircleAvatar(
            backgroundColor: Colors.grey.shade300, child: Icon(Icons.person)),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ruby Melinda Charles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('Psychology Specialist', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.badge, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text('3 yrs Experience'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text('4.7 (362 Reviews)'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child:
                Text('Details Doctor', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStats() {
    return Column(
      children: [
        _buildStatCard('Glucose Level', '168.93 mg/dL',
            'Empowering You with Healthy Glucose Levels.'),
        const SizedBox(height: 10),
        _buildStatCard('Heart Rate', '24.32 bpm',
            'Monitoring Hearts, One Beat at a Time.'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('View Details', style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
