import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:excluidos_unidos/screens/Views/assignment_view.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/task_creator_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key, required this.tasksList});
  final TaskList tasksList;

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late Stream<TaskList> listsStream;
  late Stream<List<Task>> tasksStream;

  @override
  void initState() {
    listsStream = DataProvider.instance.getList(widget.tasksList.id!);
    tasksStream = DataProvider.instance.getTasks(widget.tasksList.id!);
    super.initState();
  }

  void showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskCreatorView(
        tasksList: widget.tasksList,
      ),
    );
  }

  Future<void> deleteTask(String taskId) async {
    // Request confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content:
            const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // If confirmed, delete task
    if (confirmed == true) {
      await DataProvider.instance.deleteTask(widget.tasksList.id!, taskId);
    }
  }

  Future<void> deleteCompletedTasks() async {
    // Request confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tareas Completadas'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar las tareas completadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // If confirmed, delete task
    if (confirmed == true) {
      await DataProvider.instance.deleteCompletedTasks(widget.tasksList.id!);
    }
  }

  Future<void> assignTaskToUser(String taskId, String userId) async {
    await DataProvider.instance.assignTaskToUser(
      widget.tasksList.id!,
      taskId,
      userId,
    );
  }

  bool isTaskEnabled(Task task) {
    return (task.assignedUser == null ||
            task.assignedUser == FirebaseAuth.instance.currentUser!.uid) &&
        !task.completed;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskList>(
      stream: listsStream,
      builder: (context, snapshot) {
        final taskList = snapshot.data ?? widget.tasksList;
        return StreamBuilder<List<Task>>(
          stream: tasksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final tasks = snapshot.data ?? [];
              tasks.sort((a, b) {
                if (a.completed) {
                  return 1;
                }
                return -1;
              });

              return Scaffold(
                appBar: AppBar(
                  title: Text(taskList.name),
                  actions: [
                    IconButton(
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: TaskSearchDelegate(
                              taskLists: tasks, listTask: taskList),
                        );
                      },
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar',
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Información'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Cantidad de tareas: ${taskList.tasksQuantity}'),
                                Text(
                                    'Cantidad de tareas sin completar: ${taskList.tasksQuantity - taskList.completedTasksQuantity}'),
                                Text(
                                    'Cantidad de tareas completadas: ${taskList.completedTasksQuantity}'),
                                Text(
                                    'Cantidad de usuarios: ${taskList.usersIds.length}'),
                                const SizedBox(height: 20),
                                //show users url image as icons with their names
                                SizedBox(
                                  height: 100,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: taskList.usersIds.map((userId) {
                                        final user = DataProvider.instance
                                            .getUser(userId);
                                        return FutureBuilder<ShareableUser>(
                                          future: user,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final user = snapshot.data!;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              user.photoUrl),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      user.name.substring(
                                                        0,
                                                        user.name.contains(' ')
                                                            ? user.name
                                                                .indexOf(' ')
                                                            : user.name.length,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                          ),
                        );
                      },
                      icon: const Icon(Icons.info),
                      tooltip: 'Información',
                    ),
                    IconButton(
                      onPressed: () {
                        deleteCompletedTasks();
                      },
                      icon: const Icon(Icons.layers_clear),
                      tooltip: 'Borrar Completadas',
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: showAddTaskDialog, //te lleva a otra vista
                  child: const Icon(Icons.add),
                ),
                body: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final actionPane = ActionPane(
                      extentRatio: 0.66,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            deleteTask(task.id!);
                          },
                          label: 'Eliminar',
                          backgroundColor: Colors.red,
                          icon: Icons.clear,
                        ),
                        Visibility(
                            visible: taskList.isShared &&
                                task.assignedUser == null &&
                                task.completed == false,
                            child: SlidableAction(
                              onPressed: (context) async {
                                final String userID = await showDialog(
                                    context: context,
                                    builder: (context) => AssignUser(
                                          usersIds: taskList.usersIds,
                                          listId: taskList.id!,
                                        ));
                                assignTaskToUser(task.id!, userID);
                              },
                              label: 'Asignar',
                              backgroundColor: Colors.grey,
                              icon: Icons.person_add,
                            ))
                      ],
                    );

                    return Slidable(
                      key: Key(task.id!),
                      startActionPane: actionPane,
                      endActionPane: actionPane,
                      child: CheckboxListTile(
                        secondary: IconButton(
                          onPressed: () {
                            if (task.assignedUser != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Asignada a:'),
                                  content: SizedBox(
                                    height: 60,
                                    child: FutureBuilder<ShareableUser>(
                                      future: DataProvider.instance
                                          .getUser(task.assignedUser!),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final user = snapshot.data;
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                    user!.photoUrl),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(user.name),
                                                  const SizedBox(height: 8),
                                                  Text(user.email),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          icon: task.assignedUser != null
                              ? FutureBuilder<ShareableUser>(
                                  future: DataProvider.instance
                                      .getUser(task.assignedUser!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final user = snapshot.data;
                                      return CircleAvatar(
                                        radius: 15,
                                        backgroundImage:
                                            NetworkImage(user!.photoUrl),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                )
                              : const Icon(Icons.person_outline),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                              color: task.completed ? Colors.grey : null,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        subtitle: widget.tasksList.tasksLimitDateRequired &&
                                task.deadline != null
                            ? Text(
                                DateFormat('dd/MM/yyyy').format(task.deadline!))
                            : null,
                        value: task.completed,
                        enabled: isTaskEnabled(task),
                        onChanged: (bool? newValue) {
                          DataProvider.instance.setTaskCompleted(
                              taskList.id!, task.id!, newValue!);
                        },
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        );
      },
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
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: TextStyle(
                      color: suggestion.completed ? Colors.grey : null,
                      decoration: suggestion.completed
                          ? TextDecoration.lineThrough
                          : null),
                ),
              ),
              Checkbox(
                  value: suggestion.completed,
                  onChanged: (bool? newValue) {
                    DataProvider.instance.setTaskCompleted(
                        listTask.id!, suggestion.id!, newValue!);
                    close(context, null);
                  })
            ],
          ),
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
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: TextStyle(
                      color: suggestion.completed ? Colors.grey : null,
                      decoration: suggestion.completed
                          ? TextDecoration.lineThrough
                          : null),
                ),
              ),
              Checkbox(
                  value: suggestion.completed,
                  onChanged: (bool? newValue) {
                    DataProvider.instance.setTaskCompleted(
                        listTask.id!, suggestion.id!, newValue!);
                    close(context, null);
                  })
            ],
          ),
        );
      },
    );
  }
}
