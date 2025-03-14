import 'package:flutter/material.dart';
import 'package:pfm/screen/rota.dart';

class NewJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const NewJobScreen({super.key, this.jobData});

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController payrateontroller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      jobTitleController.text = widget.jobData!['jobTitle'] ?? "";
      payrateontroller.text = widget.jobData!['industry'] ?? "";
      descriptionController.text =
          widget.jobData!['hourlyPay']?.toString() ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.jobData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Job" : "Add New Job"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobCard(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text("Job Title",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: jobTitleController,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Hourly Pay",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: payrateontroller,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Job Description",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            rotaScreen(1),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      // MaterialPageRoute(builder: (context) => const Spending()),
                    );
                  },
                  child: const Text("View Rota",
                      style: TextStyle(color: Colors.teal))),
              TextButton(
                  onPressed: () {},
                  child: const Text("View Records",
                      style: TextStyle(color: Colors.teal))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _saveJob();
        },
        child: const Text("Save",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _saveJob() {
    // Handle job saving logic (send data to backend or store locally)
    print("Job Saved: ${jobTitleController.text}");
    // Navigator.pop(context, true);
  }
}
