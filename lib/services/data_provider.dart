import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/tasklist.dart';

class DataProvider {
  Stream<List<TaskList>> getLists() {
    return FirebaseFirestore.instance.collection('task_lists').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskList.fromJson(doc.data(), doc.id)).toList();
    });
  }

  // Get single tasklist
  Stream<TaskList> getList(String id) {
    return FirebaseFirestore.instance.collection('task_lists').doc(id).snapshots().map((doc) => TaskList.fromJson(doc.data()!, doc.id));
  }

  Future<void> addList(TaskList list) {
    return FirebaseFirestore.instance.collection('task_lists').add(list.toJson());
  }

  Future<void> updateList(TaskList list) {
    return FirebaseFirestore.instance.collection('task_lists').doc(list.id).update(list.toJson());
  }

  Future<void> deleteList(String id) {
    return FirebaseFirestore.instance.collection('task_lists').doc(id).delete();
  }

  Future<void> addTaskToTaskList(String listId, Task task) {
    final taskListDocRef = FirebaseFirestore.instance.collection('task_lists').doc(listId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final taskListDoc = await transaction.get(taskListDocRef);
      final taskList = TaskList.fromJson(taskListDoc.data()!, taskListDoc.id);
      final lastId = taskList.tasks.isEmpty ? -1 : taskList.tasks.last.id!;
      final newTask = task.copyWith(id: lastId + 1);
      final newTasks = [...taskList.tasks, newTask];
      transaction.update(taskListDocRef, {'tasks': newTasks.map((e) => e.toJson()).toList()});
    });
  }

  Future<void> setTaskCompleted(String listId, int id, bool completed) {
    final taskListDocRef = FirebaseFirestore.instance.collection('task_lists').doc(listId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final taskListDoc = await transaction.get(taskListDocRef);
      final taskList = TaskList.fromJson(taskListDoc.data()!, taskListDoc.id);
      final newTasks = taskList.tasks.map((e) => e.copyWith(completed: e.id == id ? completed : e.completed)).toList();
      transaction.update(taskListDocRef, {'tasks': newTasks.map((e) => e.toJson()).toList()});
    });
  }

  static final instance = DataProvider();
}
