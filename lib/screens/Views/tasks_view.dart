import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
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
                            visible: taskList.isShared,
                            child: SlidableAction(
                              onPressed: (context) {},
                              label: task.assignedUser != null
                                  ? "{nombre}"
                                  : 'Asignar',
                              backgroundColor: Colors.grey,
                              icon: task.assignedUser != null
                                  ? Icons.person
                                  : Icons.person_add,
                            ))
                      ],
                    );

                    return Slidable(
                      key: Key(task.id!),
                      startActionPane: actionPane,
                      endActionPane: actionPane,
                      child: CheckboxListTile(
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
