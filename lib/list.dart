import 'package:flutter/material.dart';

class ShowList extends StatefulWidget {
  const ShowList({super.key, required this.id});
  final String id;

  @override
  State<ShowList> createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.id),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) =>
              ListTile(title: Text('Tarea nro $index')),
        ));
  }
}
