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
    FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .update({'tasks_quantity': FieldValue.increment(1)});
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .add(task.toJson());
  }

  Future<void> setTaskCompleted(String listId, String taskId, bool completed) {
    FirebaseFirestore.instance.collection('task_lists').doc(listId).update({
      'completed_tasks_quantity': FieldValue.increment(1),
    });

    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'completed': completed,
      'completed_by': FirebaseAuth.instance.currentUser!.uid,
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

  Future<void> deleteTask(String listId, String taskId) async {
    final task = await getTask(listId, taskId);

    FirebaseFirestore.instance.collection('task_lists').doc(listId).update({
      'tasks_quantity': FieldValue.increment(-1),
      'completed_tasks_quantity': task.getCompleted()
          ? FieldValue.increment(-1)
          : FieldValue.increment(0),
    });

    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<Task> getTask(String listId, String taskId) async {
    final task = await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .get();
    return Task.fromJson(task.data()!, task.id);
  }

  Future<void> deleteCompletedTasks(String listId) async {
    final tasksCollection = FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks');

    final lengthCompleted = await tasksCollection
        .where('completed', isEqualTo: true)
        .get()
        .then((value) => value.docs.length);

    final completedTasksQuery =
        tasksCollection.where('completed', isEqualTo: true);

    final querySnapshot = await completedTasksQuery.get();

    final batch = FirebaseFirestore.instance.batch();

    FirebaseFirestore.instance.collection('task_lists').doc(listId).update({
      'tasks_quantity': FieldValue.increment(-lengthCompleted),
      'completed_tasks_quantity': 0,
    });

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

  Future<void> assignTaskToUser(String listId, String taskId, String userId) {
    return FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .update({'assigned_user': userId});
  }

  Future<List<ShareableUser>> getUsersFromList(String listId) async {
    final users = await FirebaseFirestore.instance
        .collection('task_lists')
        .doc(listId)
        .get();
    final usersList = users.data()!['users'] as List<dynamic>;
    final usersData = await Future.wait(usersList.map((userId) async {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return ShareableUser.fromJson(user.data()!, user.id);
    }));
    return usersData;
  }

  Future<String> getUserPhotoUrl(String userId) async {
    final user =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return user.data()!['photo_url'];
  }

  Future<ShareableUser> getUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) => ShareableUser.fromJson(doc.data()!, doc.id));
  }

  Future<String> getUserName(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) => doc.data()!['name']);
  }

  List<String> extractIdFrom(List<ShareableUser> users) {
    final List<String> usersIds = [];
    for (var user in users) {
      usersIds.add(user.id);
    }
    return usersIds;
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
