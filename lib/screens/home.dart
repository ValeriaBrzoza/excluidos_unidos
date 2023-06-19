import 'package:flutter/material.dart';
import 'package:prueba_01/screens/tasklist_creator_view.dart';
import 'package:prueba_01/services/falsedataprovider.dart';
import 'package:prueba_01/screens/tasklist_view.dart';
import 'package:prueba_01/models/tasklist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskList> listas = [];

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
              icon: Icon(Icons.search),
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        //boton de añadir lista
        onPressed: () {
          showDialog(context: context, builder: (context) => const TaskListCreatorView()); //te lleva a otra vista
          // Navigator.of(context).push(AdaptativeModalPageRoute(width: width, builder: (context) => TaskListCreatorView()));
        },
        child: const Icon(Icons.add), //icono del boton
      ),
      //Botones de la Barra de navegacion
      bottomNavigationBar: NavigationBar(
        //barrita de abajo
        destinations: const [
          //NavigationBar va a tener logica de navergacion
          NavigationDestination(
            //dibujos de abajo
            icon: Icon(Icons.list),
            label: 'My Lists',
          ),
          NavigationDestination(
            //dibujos de abajo
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
      //vista de listas
      body: ListView.builder(
        //recibe lista de widgets y los muestra en orden scroleable
        itemCount: listas.length,
        itemBuilder: (context, index) => ListTile(
          //elemento de la lista con formato de item
          title: Text(listas[index].name),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskListView(id: index.toString())));
          },
        ),
      ),
    );
  }
}


          // itemCount: 1,
          // itemBuilder: (context, index) =>
          //     ListTile(title: Text('Lista nro $index')),
