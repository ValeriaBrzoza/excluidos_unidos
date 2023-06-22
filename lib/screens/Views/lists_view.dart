import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/tasklist_creator_view.dart';
import 'package:excluidos_unidos/services/falsedataprovider.dart';
import 'package:excluidos_unidos/screens/Views/tasklist_view.dart';
import 'package:excluidos_unidos/models/tasklist.dart';

class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  List<TaskList> listas = [];
  int selectedIndex = 0;

  @override
  void initState() {
    listas = DataProvider.instance.getLists();
    super.initState(); //"BASE DE DATOS" obteniendo las listas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //devuelve vista
      appBar: AppBar(
          //vista tiene barrita arriba
          title: const Text('Mis listas de tareas'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        //boton de añadir lista
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) =>
                  const TaskListCreatorView()); //formulario de creacion de listas
        },
        child: const Icon(Icons.add), //icono del boton
      ),
      //vista de listas
      body: ListView.builder(
        //recibe lista de widgets y los muestra en orden scroleable
        itemCount: listas.length,
        itemBuilder: (context, index) => ListTile(
          //elemento de la lista con formato de item
          title: Text(listas[index].name),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TaskListView(id: index.toString())));
          },
        ),
      ),
    );
  }
}
