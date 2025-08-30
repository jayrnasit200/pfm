import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/data/models/job.dart' as JobModel;
import 'package:pfm/screen/jobedit.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:pfm/data/local/local_db.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<JobModel.job> jobs = [];
  bool isLoading = false;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() => isLoading = true);

    try {
      final db = LocalDb.isar;
      final allJobs = await db.jobs.where().findAll();

      setState(() {
        jobs = allJobs.cast<JobModel.job>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Error fetching jobs: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job List"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg))
              : jobs.isEmpty
                  ? const Center(child: Text("No jobs found."))
                  : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: ListTile(
                            title: Text(job.title ?? "No Title"),
                            subtitle: Text(job.description ?? "No Description"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobEdit(jobData: job),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewJobScreen(),
            ),
          );
        },
      ),
    );
  }
}
