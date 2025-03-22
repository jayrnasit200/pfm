import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ViewGoal extends StatelessWidget {
  final Map<String, dynamic> goal;

  ViewGoal(this.goal);

  @override
  Widget build(BuildContext context) {
    double progress = (goal["saved_amount"] / goal["target_amount"]) * 100;
    double remaining =
        goal["target_amount"].toDouble() - goal["saved_amount"].toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goal["name"],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Summary
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Slightly reduced border radius for a smaller card
              ),
              shadowColor: Colors.blueAccent.withOpacity(0.2), // Soft shadow
              child: Padding(
                padding: const EdgeInsets.all(
                    12.0), // Reduced padding to decrease height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Target Amount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          "Saved Amount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    // Title: Target Amount

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Target Amount
                        Text(
                          "£${goal["target_amount"]}",
                          style: TextStyle(
                            fontSize: 20, // Slightly smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        // Saved Amount
                        Text(
                          "£${goal["saved_amount"]}",
                          style: TextStyle(
                            fontSize: 20, // Slightly smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Reduced height between sections

                    // Title: Remaining Amount
                    Text(
                      "Remaining",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "£${remaining.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20, // Slightly smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 16), // Reduced height between sections

                    // Progress Bar
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    SizedBox(
                        height:
                            8), // Reduced height between progress and percentage

                    // Progress Percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: TextStyle(
                            fontSize:
                                16, // Reduced font size for the progress label
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          "${progress.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize:
                                16, // Reduced font size for the progress percentage
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Progress Chart
            Text("Progress Chart",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: goal["saved_amount"].toDouble(),
                          color: Colors.blue)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: remaining, color: Colors.red)
                    ]),
                  ],
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of Entries
            Text("Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Dummy count, replace with actual data
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("Entry ${index + 1}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Amount: £${(index + 1) * 1000}"),
                      trailing: Text("Date: 2025-03-${10 + index}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => SetGoals()),
          // );
        },
      ),
    );
  }
}
