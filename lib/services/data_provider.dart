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
        .update({
      'completed': completed,
      'completed_by': FirebaseAuth.instance.currentUser!.uid
    });
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

  Future<void> deleteCompletedTasks(String listId) async {
    final tasksCollection = FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks');

    final completedTasksQuery =
        tasksCollection.where('completed', isEqualTo: true);

    final querySnapshot = await completedTasksQuery.get();

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }

  Future<void> updateUserData(User user) {
    final data = {
      'email': user.email,
      'photo_url': user.photoURL,
    };

    if (user.displayName != null) {
      data['name'] = user.displayName;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
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
    if (user.docs.isEmpty) return null;
    return ShareableUser.fromJson(user.docs.first.data(), user.docs.first.id);
  }

  Future<bool> foundUser(String email) async {
    final ShareableUser? userFound = await searchForUser(email);
    return userFound != null;
  }

  static DataProvider get instance {
    return DataProvider();
  }

  Future<void> addUsersToList(String listId, List<String> users) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .update({'users': FieldValue.arrayUnion(users)});
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
      : name = json['name'] ?? (json['email'] as String).split('@').first,
        email = json['email'],
        photoUrl = json['photo_url'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
      };
}
