import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final DateTime? deadline;
  final String? assignedUser;
  final bool completed;

  const Task({
    this.id,
    required this.title,
    required this.deadline,
    required this.assignedUser,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'assigned_user': assignedUser,
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json, [String? id]) {
    return Task(
      id: id,
      title: json['title'],
      deadline: (json['deadline'] as Timestamp?)?.toDate(),
      assignedUser: json['assigned_user'],
      completed: json['completed'],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    String? assignedUser,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      assignedUser: assignedUser ?? this.assignedUser,
      completed: completed ?? this.completed,
    );
  }

  Task withCompleted(bool completed) {
    return Task(
      title: title,
      deadline: deadline,
      assignedUser: assignedUser,
      completed: completed,
    );
  }

  Task withDeadline(DateTime? deadline) {
    return Task(
      title: title,
      deadline: deadline,
      assignedUser: assignedUser,
      completed: completed,
    );
  }

  Task withAssignedUser(String? assignedUser) {
    return Task(
      title: title,
      deadline: deadline,
      assignedUser: assignedUser,
      completed: completed,
    );
  }

  Task withTitle(String title) {
    return Task(
      title: title,
      deadline: deadline,
      assignedUser: assignedUser,
      completed: completed,
    );
  }

  @override
  String toString() {
    return 'Task(title: $title, deadline: $deadline, assignedUser: $assignedUser, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.title == title &&
        other.deadline == deadline &&
        other.assignedUser == assignedUser &&
        other.completed == completed;
  }

  @override
  int get hashCode {
    return title.hashCode ^ deadline.hashCode ^ assignedUser.hashCode ^ completed.hashCode;
  }

}
