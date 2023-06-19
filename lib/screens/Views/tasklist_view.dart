import 'package:flutter/material.dart';
import 'package:prueba_01/screens/Views/task_creator_view.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key, required this.id});
  final String id;

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (context) => const TaskCreatorView());
        }, //te lleva a otra vista
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) =>
            ListTile(title: Text('Tarea nro $index')),
      ),
    );
  }
}
