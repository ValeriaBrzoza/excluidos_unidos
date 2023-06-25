import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/tasklist_creator_view.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:excluidos_unidos/screens/Views/tasklist_view.dart';
import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:intl/intl.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  int selectedIndex = 0;
  Stream<List<TaskList>> listsStream = DataProvider.instance.getLists();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //devuelve vista
      appBar: AppBar(
        //vista tiene barrita arriba
        title: const Text('Mis tareas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //boton de añadir lista
        onPressed: () async {
          final newList = await showDialog<TaskList>(context: context, builder: (context) => const TaskListCreatorView());

          if (newList == null) return; //si no se crea lista, no hace nada (cancela el dialogo)

          await DataProvider.instance.addList(newList);
        }, //formulario de creacion de listas
        child: const Icon(Icons.add), //icono del boton
      ),
      //vista de listas
      body: StreamBuilder(
        stream: listsStream,
        builder: (context, snapshot) {
          print(snapshot);

          return TaskListListView(lists: snapshot.data ?? []);
        },
      ),
    );
  }
}

class TaskListListView extends StatelessWidget {
  const TaskListListView({
    super.key,
    required this.lists,
  });

  final List<TaskList> lists;

  void showTaskList(TaskList list, BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TaskListView(
        tasksList: list,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      //recibe lista de widgets y los muestra en orden scroleable
      itemCount: lists.length,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          //icono de la lista
          child: Icon(lists[index].isShared ? Icons.people : Icons.person),
        ),
        subtitle: lists[index].hasDeadline ? Text(DateFormat('dd/MM/yyyy').format(lists[index].globalDeadline!)) : null,
        //elemento de la lista con formato de item
        title: Text(lists[index].name),
        onTap: () {
          showTaskList(lists[index], context);
        },
      ),
    );
  }
}
