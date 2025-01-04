class TaskModel {
  final int id;
  final String name;
  final String message;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final int placeId;

  TaskModel({
    required this.id,
    required this.name,
    required this.message,
    required this.startTime,
    required this.endTime,
    required this.allDay,
    required this.placeId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      allDay: json['allDay'],
      placeId: json['placeId'],
    );
  }
}
