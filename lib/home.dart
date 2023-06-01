import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:prueba_01/falsedatabase.dart';
import 'package:prueba_01/list.dart';
import 'package:prueba_01/tasklist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskList> listas = [];

  @override
  void initState() {
    // TODO: implement initState
    listas = DataProvider.instance.getLists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mis listas de tareas'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        //Botones de la Barra de navegacion
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'My Lists',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            )
          ],
        ),
        //vista de listas
        body: ListView.builder(
          itemCount: listas.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(listas[index].name),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShowList(id: index.toString())));
            },
          ),
        ));
  }
}


          // itemCount: 1,
          // itemBuilder: (context, index) =>
          //     ListTile(title: Text('Lista nro $index')),
