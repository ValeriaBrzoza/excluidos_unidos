import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/task_creator_view.dart';

import '../../models/tasks.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key, required this.id, required this.tasksList});
  final String id;
  final TaskList tasksList;

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  int index = 0;
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.tasksList.tasks;
  }

  @override
  Widget build(BuildContext context) {
    Task newTask;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          newTask = await showDialog(
            context: context,
            builder: (context) => const TaskCreatorView(),
          );
          setState(() {
            widget.tasksList.addTask(newTask);
          });
        }, //te lleva a otra vista
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) => CheckboxListTile(
          title: Text(tasks[index].title),
          value: tasks[index].isCompleted,
          onChanged: (bool? newValue) {
            setState(
              () {
                //tasks[index].complete(); ---> esto se puede poner para que, una vez completada, no se puede des-checkear
                tasks[index].isCompleted = !tasks[index].isCompleted;
              },
            );
          },
          activeColor: Colors.green,
        ),
      ),
    );
  }
}
