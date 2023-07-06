class TaskList {
  const TaskList({
    this.id,
    required this.name,
    required this.usersIds,
    required this.isShared,
    required this.tasksLimitDateRequired,
    required this.globalDeadline,
    this.tasksQuantity = 0,
    this.completedTasksQuantity = 0,
  });

  final String? id;
  final String name;
  final List<String> usersIds;
  final bool isShared;
  final bool tasksLimitDateRequired;
  final DateTime? globalDeadline;
  final int tasksQuantity;
  final int completedTasksQuantity;

  factory TaskList.fromJson(Map<String, dynamic> json, [String? id]) {
    return TaskList(
      id: id,
      name: json['name'] as String,
      usersIds:
          (json['users'] as List<dynamic>).map((e) => e.toString()).toList(),
      isShared: json['shared'] as bool,
      tasksLimitDateRequired: json['task_limit_date_required'] as bool,
      globalDeadline: json['global_deadline'] != null
          ? DateTime.parse(json['global_deadline'] as String)
          : null,
      tasksQuantity: json['tasks_quantity'] as int? ?? 0,
      completedTasksQuantity: json['completed_tasks_quantity'] as int? ?? 0,
    );
  }

  // Getter que dice si tiene o no deadline inferido de si es null o no
  bool get hasDeadline => globalDeadline != null;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "users": usersIds,
      "shared": isShared,
      "task_limit_date_required": tasksLimitDateRequired,
      "global_deadline": globalDeadline?.toIso8601String(),
      "tasks_quantity": tasksQuantity,
      "completed_tasks_quantity": completedTasksQuantity,
      // Faltan las tareas
    };
  }
}
