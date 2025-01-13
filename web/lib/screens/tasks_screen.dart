import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:web/config/config.dart';
import 'package:web/services/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> addresses = [];
  Map<int, List<Map<String, dynamic>>> jobs = {};
  Map<int, List<Map<String, dynamic>>> actualizations = {};
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      final userId = window.localStorage['userId'];
      if (userId == null) throw Exception('User ID is missing from localStorage.');

      addresses = await TaskService.getAddressesForUser(int.parse(userId));
      print('[UI] Addresses fetched: $addresses');

      for (final address in addresses) {
        final addressId = address['addressId'];
        final tasks = await TaskService.fetchTasksByAddress(addressId);
        jobs[addressId] = tasks;

        for (final job in tasks) {
          final jobId = job['id'];
          try {
            final jobActualizations = await TaskService.fetchJobActualizations(jobId);
            actualizations[jobId] = jobActualizations;
            print('[UI] Job Actualizations for Job ID: $jobId: $jobActualizations');
          } catch (e) {
            actualizations[jobId] = [];
            print('[UI] No actualizations found for Job ID: $jobId');
          }
        }

       
jobs[addressId] = tasks;

for (final job in tasks) {
  final jobId = job['id']; // Job ID
  final teamId = job['addressId']; // Fetch teamId directly from the job data
  if (teamId != null) {
    print('[UI] Team ID for Job ID $jobId: $teamId');
  } else {
    print('[UI] Team ID not found for Job ID $jobId');
  }
}

      }
    } catch (e) {
      setState(() {
        _isError = true;
      });
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadDataForJob(int jobId) async {
    try {
      final jobActualizations = await TaskService.fetchJobActualizations(jobId);
      setState(() {
        actualizations[jobId] = jobActualizations;
      });
      print('[UI] Reloaded actualizations for Job ID: $jobId: $jobActualizations');
    } catch (e) {
      setState(() {
        actualizations[jobId] = [];
      });
      print('[UI] No actualizations found for Job ID: $jobId');
    }
  }

  Future<void> _toggleJobActualizationStatus(int actualizationId, int jobId) async {
    try {
      await TaskService.toggleJobActualizationStatus(actualizationId);
      await _reloadDataForJob(jobId);
      print('[UI] Toggled status for Job Actualization ID: $actualizationId');
    } catch (e) {
      print('Error toggling status for job actualization ID $actualizationId: $e');
    }
  }

  Future<void> _deleteJob(int jobId, int addressId) async {
    try {
      await TaskService.deleteJob(jobId);
      print('[UI] Successfully deleted Job ID: $jobId');

      setState(() {
        jobs[addressId] = jobs[addressId]!.where((job) => job['id'] != jobId).toList();
        actualizations.remove(jobId);
        if (jobs[addressId]!.isEmpty) {
          jobs.remove(addressId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting Job ID: $jobId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete job: $e')),
      );
    }
  }

  Future<void> _addTask(int addressId) async {
    final nameController = TextEditingController();
    final messageController = TextEditingController();
    DateTime? startTime, endTime;

    await showDialog(
      context: context,
      builder: (context) {
        bool allDay = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => startTime = date);
                        }
                      },
                      child: const Text('Start Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      startTime != null
                          ? '${startTime!.year}-${startTime!.month.toString().padLeft(2, '0')}-${startTime!.day.toString().padLeft(2, '0')}'
                          : 'Select Start Time',
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => endTime = date);
                        }
                      },
                      child: const Text('End Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      endTime != null
                          ? '${endTime!.year}-${endTime!.month.toString().padLeft(2, '0')}-${endTime!.day.toString().padLeft(2, '0')}'
                          : 'Select End Time',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: allDay,
                      onChanged: (value) {
                        setState(() {
                          allDay = value!;
                        });
                      },
                    ),
                    const Text('All Day'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      messageController.text.isNotEmpty &&
                      startTime != null &&
                      endTime != null) {
                    final adjustedStartTime = allDay
                        ? DateTime(startTime!.year, startTime!.month, startTime!.day, 0, 0, 0).toUtc()
                        : startTime!.toUtc();
                    final adjustedEndTime = allDay
                        ? DateTime(endTime!.year, endTime!.month, endTime!.day, 23, 59, 59).toUtc()
                        : endTime!.toUtc();

                    await TaskService.addJob(
                      name: nameController.text,
                      message: messageController.text,
                      startTime: adjustedStartTime,
                      endTime: adjustedEndTime,
                      allDay: allDay,
                      addressId: addressId,
                    );
                    Navigator.pop(context);
                    await _fetchData();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _assignUser(int jobId, int teamId) async {
    try {
      final teammates = await TaskService.fetchTeammates(teamId);
      int? selectedUserId;
      String selectedUserName = "Select a user";

      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Assign User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: selectedUserId,
                  isExpanded: true,
                  hint: Text(selectedUserName),
                  items: teammates.map((user) {
                    return DropdownMenuItem<int>(
                      value: user['id'],
                      child: Text('${user['name']} ${user['surname']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                      final selectedUser = teammates.firstWhere((user) => user['id'] == value);
                      selectedUserName = '${selectedUser['name']} ${selectedUser['surname']}';
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedUserId != null) {
                    await TaskService.assignUserToTask(jobId, selectedUserId!);
                    Navigator.pop(context);
                    await _reloadDataForJob(jobId);
                  }
                },
                child: const Text('Assign'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error assigning user to job ID $jobId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign user: $e')),
      );
    }
  }

  Widget _buildImageList(List<String> images) {
    return images.isNotEmpty
        ? SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Image.network(imageUrl, fit: BoxFit.contain),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          )
        : const Text('No images available.');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return const Center(
        child: Text(
          'Failed to load data',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
      ),
      body: ListView(
        children: addresses.map((address) {
          final addressId = address['addressId'];
          final addressJobs = jobs[addressId] ?? [];

          return ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address['name']),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(addressId),
                ),
              ],
            ),
            children: addressJobs.map((job) {
              final jobId = job['id'];
              final jobActualizations = actualizations[jobId] ?? [];

              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(job['name']),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () {
                            final teamId = address['teamId'];
                            if (teamId != null) {
                              _assignUser(jobId, teamId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Team ID not found for this job.')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteJob(jobId, addressId),
                        ),
                      ],
                    ),
                  ],
                ),
                children: jobActualizations.isEmpty
                    ? [const ListTile(title: Text('No actualizations were posted'))]
                    : jobActualizations.map((actualization) {
                        final images = actualization['jobImageUrl'] as List<String>;
                        return Column(
                          children: [
                            ListTile(
                              title: Text(actualization['message']),
                              trailing: IconButton(
                                icon: Icon(
                                  actualization['isDone']
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: actualization['isDone'] ? Colors.green : Colors.grey,
                                ),
                                onPressed: () async {
                                  await _toggleJobActualizationStatus(actualization['id'], jobId);
                                },
                              ),
                            ),
                            _buildImageList(images),
                          ],
                        );
                      }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
