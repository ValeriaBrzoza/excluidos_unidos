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
        content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
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


  //TODO: agregarle animaciones
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskList>(
      stream: listsStream,
      builder: (context, snapshot) {
        final taskList = snapshot.data ?? widget.tasksList;

        return StreamBuilder<List<Task>>(
          stream: tasksStream,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            tasks.sort((a, b) {
              if(a.completed) {
                return 1;
              }
              return -1;
            });

            return Scaffold(
              appBar: AppBar(
                title: Text(taskList.name),
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
                      SlidableAction(
                        onPressed: (context) {},
                        label: task.assignedUser != null ? "{nombre}" : 'Asignar',
                        backgroundColor: Colors.grey,
                        icon: task.assignedUser != null ? Icons.person : Icons.person_add,
                      )
                    ],
                  );

                  return Slidable(
                    key: Key(task.id!),
                    startActionPane: actionPane,
                    endActionPane: actionPane,
                    child: CheckboxListTile(
                      title: Text(task.title,
                        style: TextStyle(
                          color: task.completed ?  Colors.grey : null,
                          decoration: task.completed ? TextDecoration.lineThrough : null),),
                      subtitle: widget.tasksList.tasksLimitDateRequired && task.deadline != null
                          ? Text(DateFormat('dd/MM/yyyy').format(task.deadline!))
                          : null,
                      value: task.completed,
                      //activeColor: task.completed ?  Colors.grey : null,
                      onChanged: (bool? newValue) {
                        DataProvider.instance.setTaskCompleted(taskList.id!, task.id!, newValue!);
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
