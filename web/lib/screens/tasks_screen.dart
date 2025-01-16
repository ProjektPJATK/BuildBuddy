import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:web/config/config.dart';
import 'package:web/services/task_service.dart';
import 'package:web/themes/styles.dart';
import 'package:universal_html/html.dart' as html;

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
    _startPowerLevelRefetch(); // Start periodic refetching
  }
@override
 

 


  late Timer _powerLevelTimer; // Declare the timer
  Map<int, int> teamPowerLevels = {}; // Store power levels for teams

 @override
void dispose() {
  // Unfocus any text fields or HTML inputs before disposing
  FocusScope.of(context).unfocus();

  // Cancel your timer to avoid memory leaks
  _powerLevelTimer.cancel();
  super.dispose();
}

  void _startPowerLevelRefetch() {
    _powerLevelTimer = Timer.periodic(
      const Duration( minutes: 5), // Refetch every 5 minutes
      (timer) async {
        await _refetchPowerLevels(); // Method to refetch power levels
      },
    );
  }

  Future<void> _refetchPowerLevels() async {
  try {
    final updatedPowerLevels = await getTeamPowerLevels(); // Fetch updated power levels
    setState(() {
      teamPowerLevels = updatedPowerLevels; // Update state with new power levels
    });

    // Update localStorage with the latest power levels
    html.window.localStorage['teamsWithPowerLevels'] = json.encode([
      for (var entry in updatedPowerLevels.entries)
        {'teamId': entry.key, 'powerLevel': entry.value}
    ]);

    print('[UI] Updated Power Levels: $teamPowerLevels');
  } catch (e) {
    print('[UI] Error refetching power levels: $e');
  }
}

   Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      // Initial power level fetch
      teamPowerLevels = getTeamPowerLevels();
      print('[UI] Team Power Levels: $teamPowerLevels');

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
          backgroundColor: AppStyles.transparentWhite, // Apply transparent background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners for dialog
          ),
          title: const Text('Add Task', style: AppStyles.headerStyle), // Styled title
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: AppStyles.inputFieldStyle(hintText: 'Name'), // Styled input field
                  cursorColor: AppStyles.cursorColor,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  decoration: AppStyles.inputFieldStyle(hintText: 'Message'), // Styled input field
                  cursorColor: AppStyles.cursorColor,
                ),
                const SizedBox(height: 20),
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
                      style: AppStyles.textButtonStyle(), // Styled button
                      child: const Text('Start Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      startTime != null
                          ? '${startTime!.year}-${startTime!.month.toString().padLeft(2, '0')}-${startTime!.day.toString().padLeft(2, '0')}'
                          : 'Select Start Time',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                      style: AppStyles.textButtonStyle(), // Styled button
                      child: const Text('End Time'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      endTime != null
                          ? '${endTime!.year}-${endTime!.month.toString().padLeft(2, '0')}-${endTime!.day.toString().padLeft(2, '0')}'
                          : 'Select End Time',
                      style: AppStyles.textStyle, // Styled text
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                    const Text('All Day', style: AppStyles.textStyle), // Styled text
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: AppStyles.textButtonStyle(), // Styled text button
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
              style: AppStyles.buttonStyle(), // Styled button
              child: const Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _manageUsers(int jobId, int addressId) async {
  try {
    final assignedUsers = await TaskService.fetchAssignedUsers(jobId);
    final allTeammates = await TaskService.fetchTeamMembers(addressId);

    // Check for empty lists
    if (assignedUsers.isEmpty) {
      print('No assigned users for job ID: $jobId.');
    }

    final availableUsers = allTeammates
        .where((user) => !assignedUsers.any((assigned) => assigned['id'] == user['id']))
        .toList();

    List<int> selectedUserIds = [];
    List<Map<String, dynamic>> selectedUsers = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Manage Users'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show message if no assigned users
                  if (assignedUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No users currently assigned to this job.'),
                    ),
                  // Show Assigned Users with Delete Option
                  if (assignedUsers.isNotEmpty)
                    ...assignedUsers.map((user) {
                      return ListTile(
                        title: Text('${user['name']} ${user['surname']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 0, 0, 0)),
                          onPressed: () async {
                            await TaskService.deleteUserFromJob(jobId, user['id']);
                            setState(() {
                              assignedUsers.remove(user);
                              availableUsers.add(user);
                            });
                            await _reloadDataForJob(jobId);
                          },
                        ),
                      );
                    }).toList(),
                  const Divider(), // Separator between assigned users and add user section
                  // Add Unassigned Users Section
                  if (availableUsers.isNotEmpty)
                    ...availableUsers.map((user) {
                      final isSelected = selectedUserIds.contains(user['id']);
                      return CheckboxListTile(
                        title: Text('${user['name']} ${user['surname']}'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedUserIds.add(user['id']);
                              selectedUsers.add(user);
                            } else {
                              selectedUserIds.remove(user['id']);
                              selectedUsers.removeWhere((u) => u['id'] == user['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  // Show message if no available users
                  if (availableUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No unassigned users available to add.'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedUserIds.isNotEmpty) {
                    for (int userId in selectedUserIds) {
                      await TaskService.assignUserToTask(jobId, userId);
                      final assignedUser =
                          availableUsers.firstWhere((user) => user['id'] == userId);
                      setState(() {
                        availableUsers.remove(assignedUser);
                        assignedUsers.add(assignedUser);
                      });
                    }
                    selectedUserIds.clear();
                    selectedUsers.clear();
                    await _reloadDataForJob(jobId);
                  }
                },
                child: const Text('Add Selected Users'),
              ),
            ],
          );
        },
      ),
    );
  } catch (e) {
    print('Error managing users for job ID $jobId: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to manage users: $e')),
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
      title: const Text('Manage Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color.fromARGB(144, 81, 85, 87),
    ),
    body: Container(
      decoration: AppStyles.backgroundDecoration,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: addresses.map((address) {
          final addressId = address['addressId'];
          final addressName = address['name'];
          final addressJobs = jobs[addressId] ?? [];
          final teamId = address['id'];
          final powerLevel = teamPowerLevels[teamId] ?? 0;

          // Skip address if power level is insufficient
          if (powerLevel < 2) {
            print('[UI] Skipping address ID $addressId due to insufficient power level: $powerLevel');
            return const SizedBox.shrink();
          }

          print('[UI] Displaying address ID $addressId with sufficient power level: $powerLevel');

          // Always return an ExpansionTile for this address
          return Card(
            color: AppStyles.transparentWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    addressName,
                    style: AppStyles.headerStyle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
                    onPressed: () => _addTask(addressId),
                  ),
                ],
              ),
              // If addressJobs is empty, show a single "No jobs" tile
              children: addressJobs.isEmpty
                  ? [
                      const ListTile(
                        title: Text(
                          'There are no jobs for this team',
                          style: AppStyles.textStyle,
                        ),
                      ),
                    ]
                  : addressJobs.map((job) {
                      final jobId = job['id'];
                      final jobName = job['name'];
                      final jobActualizations = actualizations[jobId] ?? [];

                      return ExpansionTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(jobName, style: AppStyles.textStyle),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.person_add, color: AppStyles.primaryBlue),
                                      onPressed: () => _manageUsers(jobId, addressId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 10, 10, 10)),
                                      onPressed: () => _deleteJob(jobId, addressId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (jobActualizations.isNotEmpty)
                              const Divider(
                                color: Colors.black26,
                                thickness: 1,
                                indent: 8,
                                endIndent: 8,
                              ),
                          ],
                        ),
                        // If jobActualizations is empty, show the "Workers did not post updates" tile
                        children: jobActualizations.isEmpty
                            ? [
                                const ListTile(
                                  title: Text(
                                    'Workers did not post any updates on their jobs',
                                    style: AppStyles.textStyle,
                                  ),
                                ),
                              ]
                            : jobActualizations.map((actualization) {
                                final images = actualization['jobImageUrl'] as List<String>;
                                final isDone = actualization['isDone'] == true;

                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        actualization['message'],
                                        style: AppStyles.textStyle,
                                      ),
                                      trailing: isDone
                                          // Accepted State: Blue background, white text
                                          ? ElevatedButton.icon(
                                              icon: const Icon(Icons.check_circle,  color: Colors.white,),
                                            
                                              label: const Text('Accepted'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 2, 107, 245),
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                // Optionally toggle back if desired
                                                await _toggleJobActualizationStatus(actualization['id'], jobId);
                                              },
                                            )
                                          // Accept State: White background, light-blue text
                                          : ElevatedButton.icon(
                                              icon: const Icon(Icons.radio_button_unchecked, color: Color.fromARGB(255, 1, 112, 240),),
                                              label: const Text('Accept'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(0xFF026BF5),
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
            ),
          );
        }).toList(),
      ),
    ),
  );
}





int getUserPowerLevel(int teamId) {
  final String? powerLevelsJson = html.window.localStorage['teamsWithPowerLevels'];
  if (powerLevelsJson == null || powerLevelsJson.isEmpty) {
    return 0; // No power level found
  }

  try {
    final List<dynamic> teamsWithPowerLevels = json.decode(powerLevelsJson);
    final team = teamsWithPowerLevels.firstWhere(
      (entry) => entry['teamId'] == teamId,
      orElse: () => null,
    );

    if (team != null && team['powerLevel'] != null) {
      return int.tryParse(team['powerLevel'].toString()) ?? 0;
    }
  } catch (e) {
    print('Error fetching user power level: $e');
  }
  return 0; // Default to no privileges
}

// Parse team power levels
  Map<int, int> getTeamPowerLevels() {
    final String? powerLevelsJson = html.window.localStorage['teamsWithPowerLevels'];
    if (powerLevelsJson == null || powerLevelsJson.isEmpty) {
      return {};
    }

    try {
      final List<dynamic> teamsWithPowerLevels = json.decode(powerLevelsJson);
      return {for (var entry in teamsWithPowerLevels) entry['teamId']: entry['powerLevel']};
    } catch (e) {
      print('[UI] Error Parsing Power Levels: $e');
      return {};
    }
  }


}