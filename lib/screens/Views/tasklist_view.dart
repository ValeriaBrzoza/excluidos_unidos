import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/task_creator_view.dart';

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
                itemBuilder: (context, index) => CheckboxListTile(
                  title: Text(tasks[index].title),
                  value: tasks[index].completed,
                  onChanged: (bool? newValue) {
                    DataProvider.instance.setTaskCompleted(taskList.id!, tasks[index].id!, newValue!);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
