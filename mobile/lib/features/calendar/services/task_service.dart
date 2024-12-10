class TaskService {
  static List<Map<String, dynamic>> getTasks() {
    return [
      {
        "id": 0,
        "name": "Przywóz materiałów",
        "message": "Kurier przywiezie materiały na budowę.",
        "startTime": DateTime.parse("2024-12-02T10:00:00.000Z"),
        "endTime": DateTime.parse("2024-12-04T18:00:00.000Z"),
        "allDay": true,
        "placeId": 1,
      },
      {
        "id": 1,
        "name": "Szpachlowanie gładzi",
        "message": "Szpachlowanie ścian w salonie.",
        "startTime": DateTime.parse("2024-12-03T08:00:00.000Z"),
        "endTime": DateTime.parse("2024-12-03T12:00:00.000Z"),
        "allDay": false,
        "placeId": 1,
      },
    ];
  }

  static List<Map<String, dynamic>> getTasksForDay(
    List<Map<String, dynamic>> tasks,
    DateTime day,
  ) {
    return tasks.where((task) {
      final start = task['startTime'] as DateTime;
      final end = task['endTime'] as DateTime;
      return day.isAfter(start.subtract(const Duration(days: 1))) &&
          day.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
