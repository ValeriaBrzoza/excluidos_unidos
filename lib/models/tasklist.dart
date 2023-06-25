// Ejemplo de lista de tareas
// Falta todo el tema de las tareas en si

class TaskList {
  const TaskList({
    this.id,
    required this.name,
    required this.usersIds,
    required this.isShared,
    required this.supervisorsIds,
    required this.tasksLimitDateRequired,
    required this.globalDeadline,
  });

  final String? id;
  final String name;
  final List<String> usersIds;
  final bool isShared;
  final List<String> supervisorsIds;
  final bool tasksLimitDateRequired;
  final DateTime? globalDeadline;

  factory TaskList.fromJson(Map<String, dynamic> json, [String? id]) {
    return TaskList(
      id: id,
      name: json['name'] as String,
      usersIds: (json['users'] as List<dynamic>).map((e) => e.toString()).toList(),
      supervisorsIds: (json['supervisors'] as List<dynamic>).map((e) => e.toString()).toList(),
      isShared: json['shared'] as bool,
      tasksLimitDateRequired: json['task_limit_date_required'] as bool,
      globalDeadline: json['global_deadline'] != null ? DateTime.parse(json['global_deadline'] as String) : null,
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
}
