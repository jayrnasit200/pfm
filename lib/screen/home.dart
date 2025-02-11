// import 'package:flutter/material.dart';
// import 'package:pfm/NavigationBar.dart';

// class homescreen extends StatefulWidget {
//   const homescreen({super.key});

//   @override
//   State<homescreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<homescreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: NavigationBars("home"),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 20),
//               _buildDoctorCard(),
//               const SizedBox(height: 20),
//               _buildHealthStats(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Icon(Icons.search, size: 30, color: Colors.grey.shade800),
//         Text(
//           'Medicalic',
//           style: TextStyle(
//               fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
//         ),
//         CircleAvatar(
//             backgroundColor: Colors.grey.shade300, child: Icon(Icons.person)),
//       ],
//     );
//   }

//   Widget _buildDoctorCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Ruby Melinda Charles',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Text('Psychology Specialist', style: TextStyle(color: Colors.grey)),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.badge, color: Colors.blue),
//                   const SizedBox(width: 5),
//                   Text('3 yrs Experience'),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber),
//                   const SizedBox(width: 5),
//                   Text('4.7 (362 Reviews)'),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//             child:
//                 Text('Details Doctor', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHealthStats() {
//     return Column(
//       children: [
//         _buildStatCard('Glucose Level', '168.93 mg/dL',
//             'Empowering You with Healthy Glucose Levels.'),
//         const SizedBox(height: 10),
//         _buildStatCard('Heart Rate', '24.32 bpm',
//             'Monitoring Hearts, One Beat at a Time.'),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, String subtitle) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(title,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               Text('View Details', style: TextStyle(color: Colors.blue)),
//             ],
//           ),
//           const SizedBox(height: 5),
//           Text(value,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 5),
//           Text(subtitle, style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/Auth/login.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
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
              buildHeader(), // Updated call
              const SizedBox(height: 20),
              _buildDiarySection(),
              const SizedBox(height: 20),
              _buildMealsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    // Updated method name
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Diary',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Row(
          children: [
            ElevatedButton(
              child: const Text('Open route'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade800),
            const SizedBox(width: 5),
            const Text('15 May', style: TextStyle(color: Colors.black)),
          ],
        ),
      ],
    );
  }

  Widget _buildDiarySection() {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mediterranean diet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Eaten: 1127 kcal  Burned: 102 kcal'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularProgress(1503),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Carbs: 12g left'),
                  Text('Protein: 30g left'),
                  Text('Fat: 10g left'),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMealCard(
            'Breakfast',
            'https://cdn3d.iconscout.com/3d/premium/thumb/transfer-money-3d-icon-download-in-png-blend-fbx-gltf-file-formats--share-currency-pack-business-icons-5631692.png',
            525,
            Colors.orange.shade200),
        _buildMealCard(
            'Lunch',
            'https://static.vecteezy.com/system/resources/thumbnails/026/977/015/small_2x/money-bag-cash-dollar-earning-investment-savings-business-coin-gold-plastic-3d-icon-ai-generated-png.png',
            602,
            Colors.blue.shade200),
        _buildMealCard(
            'Lunch',
            'https://cdn3d.iconscout.com/3d/premium/thumb/online-transfer-3d-icon-download-in-png-blend-fbx-gltf-file-formats--payment-finance-money-pack-business-icons-6777647.png?f=webp',
            602,
            Colors.pink.shade200),
      ],
    );
  }

  Widget _buildCircularProgress(double progressValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            value: progressValue / 2000, // Example normalization
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Text(
          '${progressValue.toInt()} kcal',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildMealCard(
      String title, String subtitle, int calories, Color backgroundColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          // borderRadius: BorderRadius.circular(16),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(70),
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.network(subtitle),
            Image.network(
              subtitle,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                    'assets/images/placeholder.png'); // Fallback image
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            // const SizedBox(height: 5),
            // Text(
            //   subtitle,
            //   style: const TextStyle(color: Colors.black),
            // ),
            const SizedBox(height: 5),
            Text(
              '$calories kcal',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
