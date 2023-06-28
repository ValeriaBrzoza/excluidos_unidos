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

  ShareableUser? userToAdd;

  Timer? showAddButtonTimer;

  List<ShareableUser> usersToAdd = [];

  bool isAddButtonEnabled() {
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
                  onChanged: (email) async {
                    final userFound =
                        await DataProvider.instance.searchForUser(email);
                    setState(
                      () {
                        if (userFound != null) {
                          userToAdd = userFound;
                          enableAddButton = true;
                        } else {
                          userToAdd = null;
                          enableAddButton = false;
                        }
                        ;
                      },
                    );
                  },
                  decoration: const InputDecoration(
                    //visual del textfield
                    labelText: 'Añadir usuario por email',
                    filled: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: isAddButtonEnabled()
                        ? () {
                            usersToAdd.add(userToAdd!);
                          }
                        : null,
                    child: const SizedBox(
                      height: 20,
                      width: 60,
                      child: Center(
                        child: Text('Add'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
