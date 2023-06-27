import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/tasklist.dart';

class DataProvider {
  Stream<List<TaskList>> getLists(String idUser) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .where('users', arrayContains: idUser)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskList.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single tasklist
  Stream<TaskList> getList(String id) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(id)
        .snapshots()
        .map((doc) => TaskList.fromJson(doc.data()!, doc.id));
  }

  Future<void> addList(TaskList list) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .add(list.toJson());
  }

  Future<void> updateList(TaskList list) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(list.id)
        .update(list.toJson());
  }

  Future<void> deleteList(String id) {
    return FirebaseFirestore.instance.collection('task_lists').doc(id).delete();
  }

  Future<void> addTaskToTaskList(String listId, Task task) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .add(task.toJson());
  }

  Future<void> setTaskCompleted(String listId, String taskId, bool completed) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .update({'completed': completed});
  }

  Stream<List<Task>> getTasks(String listId) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> deleteTask(String listId, String taskId) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> updateUserData(User user) {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': user.displayName,
      'email': user.email,
      'photo_url': user.photoURL,
    });
  }

  Future<void> updateNotificationsToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(fcmToken)
        .set({'user_id': user.uid}, SetOptions(merge: true));
  }

  Future<ShareableUser?> searchForUser(String email) async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return ShareableUser.fromJson(user.docs.first.data(), user.docs.first.id);
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
  Stream<List<TaskList>> getLists(String idUser) {
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

  @override
  Future<ShareableUser?> searchForUser(String email) {
    // TODO: implement searchForUser
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserData(User user) {
    // TODO: implement updateUserData
    throw UnimplementedError();
  }

  @override
  Future<void> updateNotificationsToken() {
    // TODO: implement updateNotificationsToken
    throw UnimplementedError();
  }
}

class ShareableUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;

  ShareableUser(
      {required this.name,
      required this.email,
      required this.photoUrl,
      required this.id});

  ShareableUser.fromJson(Map<String, dynamic> json, this.id)
      : name = json['name'],
        email = json['email'],
        photoUrl = json['photo_url'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
      };
}
