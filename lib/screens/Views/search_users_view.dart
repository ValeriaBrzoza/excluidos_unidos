import 'dart:async';

import 'package:flutter/material.dart';
import 'package:excluidos_unidos/services/data_provider.dart';

import '../../models/tasklist.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  bool enableAddButton = false;

  Timer? showAddButtonTimer;

  bool isAddButtonEnable() {
    return enableAddButton;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 516,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Buscar usuarios'),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              //isSaveButtomEnabled() ? () => {} : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: null, //isSaveButtomEnabled() ? complete : null,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text("Agregar"),
                  )
                ],
              ),
            ),
            body: Column(
              children: [
                TextField(
                  //recuadro de texto para el nombre de la lista

                  onChanged: (value) {
                    setState(() {
                      var email = value;
                      print(DataProvider.instance.existeUsuario(email));
                    });
                  },
                  decoration: const InputDecoration(
                    //visual del textfield
                    labelText: 'Añadir usuario por email',
                    filled: true,
                  ),
                ),
                FloatingActionButton(
                  onPressed: isAddButtonEnable() ? () {} : null,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/*
class UserSearchDelegate extends SearchDelegate {
  UserSearchDelegate({
    required this.usersList,
  });

  final List<String> usersList;

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
    final searchResults = usersList
        .where((user) => user.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return ListTile(
          title: Text(user),
          onTap: () {
/*             query = taskList.name;
            close(context, null);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskListView(
                tasksList: taskList,
              ), 
            ));*/
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchResults = usersList
        .where((user) => user.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final taskList = searchResults[index];
        return ListTile(
          title: Text(taskList),
          onTap: () {
            /* query = taskList.name;
            close(context, null);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskListView(
                tasksList: taskList,
              ),
            )); */
          },
        );
      },
    );
  }
}
*/