// Ejemplo de lista de tareas
// Falta todo el tema de las tareas en si
import 'package:excluidos_unidos/models/tasks.dart';

class TaskList {
  TaskList({
    required this.name,
    required this.usersIds,
    required this.isShared,
    required this.supervisorsIds,
    required this.tasksLimitDateRequired,
    required this.globalDeadline,
  });

  final String name;
  final List<String> usersIds;
  final bool isShared;
  final List<String> supervisorsIds;
  final bool tasksLimitDateRequired;
  final DateTime? globalDeadline;
  List<Task> tasks = [];

  factory TaskList.fromJson(Map<String, Object> json) {
    return TaskList(
      name: json['name'] as String,
      usersIds: json['users'] as List<String>,
      supervisorsIds: json['supervisors'] as List<String>,
      isShared: json['shared'] as bool,
      tasksLimitDateRequired: json['task_limit_date_required'] as bool,
      globalDeadline: json['global_deadline'] != null
          ? DateTime.parse(json['global_deadline'] as String)
          : null,
    );
  }

  // Getter que dice si tiene o no deadline inferido de si es null o no
  bool get hasDeadline => globalDeadline != null;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "users": usersIds,
      "shared": isShared,
      "supervisors": supervisorsIds,
      "task_limit_date_required": tasksLimitDateRequired,
      "global_deadline": globalDeadline?.toIso8601String(),
      // Faltan las tareas
    };
  }

  void addTask(Task newTask) {
    tasks.add(newTask);
  }

  List<Task> get tasksList => tasks;
}
