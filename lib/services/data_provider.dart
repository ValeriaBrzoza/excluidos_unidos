import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return FirebaseFirestore.instance.collection('task_lists').doc(listId).collection('tasks').add(task.toJson());
  }

  Future<void> setTaskCompleted(String listId, String taskId, bool completed) {
    return FirebaseFirestore.instance.collection('task_lists').doc(listId).collection('tasks').doc(taskId).update({'completed': completed});
  }

  Stream<List<Task>> getTasks(String listId) {
    return FirebaseFirestore.instance.collection('task_lists').doc(listId).collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteTask(String listId, String taskId) {
    return FirebaseFirestore.instance.collection('task_lists').doc(listId).collection('tasks').doc(taskId).delete();
  }

  static DataProvider get instance {
    if (FirebaseAuth.instance.currentUser == null) {
      return DataProviderGuest();
    } else {
      return DataProvider();
    }
  }
}

class DataProviderGuest implements DataProvider {
  @override
  Future<void> addList(TaskList list) {
    // TODO: implement addList
    throw UnimplementedError();
  }

  @override
  Future<void> addTaskToTaskList(String listId, Task task) {
    // TODO: implement addTaskToTaskList
    throw UnimplementedError();
  }

  @override
  Future<void> deleteList(String id) {
    // TODO: implement deleteList
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String listId, String taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Stream<TaskList> getList(String id) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Stream<List<TaskList>> getLists() {
    // TODO: implement getLists
    throw UnimplementedError();
  }

  @override
  Stream<List<Task>> getTasks(String listId) {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<void> setTaskCompleted(String listId, String taskId, bool completed) {
    // TODO: implement setTaskCompleted
    throw UnimplementedError();
  }

  @override
  Future<void> updateList(TaskList list) {
    // TODO: implement updateList
    throw UnimplementedError();
  }
}
