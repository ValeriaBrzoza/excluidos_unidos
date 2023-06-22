class Task {
  final String title;
  bool hasDeadLine = false;
  bool isCompleted = false;
  DateTime? taskDeadline;
  String? assignedUser;

  Task({
    required this.title,
  });

  void addDeadLine(DateTime deadLine) {
    hasDeadLine = true;
    taskDeadline = deadLine;
  }

  void assignTo(String user) {
    assignedUser = user;
  }

  void complete() {
    isCompleted = true;
  }

  bool get state => isCompleted;
}
