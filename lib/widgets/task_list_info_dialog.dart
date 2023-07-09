import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskListInfoDialog extends StatelessWidget {
  const TaskListInfoDialog({
    super.key,
    required this.taskList,
  });

  final TaskList taskList;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Información'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.circle, size: 14),
            title: Text('Tareas: ${taskList.tasksQuantity}'),
          ),
          ListTile(
            leading: const Icon(Icons.circle, size: 14),
            title: Text('Sin completar: ${taskList.tasksQuantity - taskList.completedTasksQuantity}'),
          ),
          ListTile(
            leading: const Icon(Icons.circle, size: 14),
            title: Text('Completadas: ${taskList.completedTasksQuantity}'),
          ),
          ListTile(
            leading: const Icon(Icons.circle, size: 14),
            title: Text('Fecha Límite:  ${taskList.hasDeadline ? DateFormat('dd/MM/yyyy').format(taskList.globalDeadline!) : 'No tiene'}'),
          ),
          ListTile(
            leading: const Icon(Icons.circle, size: 14),
            title: Text('Usuarios: ${taskList.usersIds.length}'),
          ),
          const SizedBox(height: 20),
          //show users url image as icons with their names
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: taskList.usersIds.map((userId) {
                  final user = DataProvider.instance.getUser(userId);
                  return FutureBuilder<ShareableUser>(
                    future: user,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final user = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(user.photoUrl),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.name.substring(
                                  0,
                                  user.name.contains(' ') ? user.name.indexOf(' ') : user.name.length,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class TaskSearchDelegate extends SearchDelegate {
  TaskSearchDelegate({
    required this.taskLists,
    required this.listTask,
  });

  final List<Task> taskLists;
  final TaskList listTask;

  bool isTaskEnabled(Task task) {
    return (task.assignedUser == null || task.assignedUser == DataProvider.instance.currentUser.uid) && !task.completed;
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => close(context, null),
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    List<Task> suggestions = taskLists.where((searchResult) {
      final result = searchResult.title.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var suggestion = suggestions[index];
        return CheckboxListTile(
          key: Key(suggestion.id!),
          title: Text(
            suggestion.title,
            style: TextStyle(
              color: suggestion.completed ? Colors.grey : null,
              decoration: suggestion.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          value: suggestion.completed,
          enabled: isTaskEnabled(suggestion),
          onChanged: (bool? newValue) {
            DataProvider.instance.setTaskCompleted(listTask.id!, suggestion.id!, newValue!);
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Task> suggestions = taskLists.where((searchResult) {
      final result = searchResult.title.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return CheckboxListTile(
          title: Text(
            suggestion.title,
            style: TextStyle(
              color: suggestion.completed ? Colors.grey : null,
              decoration: suggestion.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          value: suggestion.completed,
          enabled: isTaskEnabled(suggestion),
          onChanged: (bool? newValue) {
            DataProvider.instance.setTaskCompleted(listTask.id!, suggestion.id!, newValue!);
            close(context, null);
          },
        );
      },
    );
  }
}
