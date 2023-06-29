import 'dart:async';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/services/data_provider.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key, required this.authorId});

  final String authorId;

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  bool enableAddButton = false;

  ShareableUser? userToAdd;

  Timer? showAddButtonTimer;

  List<ShareableUser> usersToAdd = [];

  bool isAddUserButtonEnabled() {
    return enableAddButton;
  }

  List<String> extractIdFrom(List<ShareableUser> users) {
    final List<String> usersToAddIds = [];
    for (var user in users) {
      usersToAddIds.add(user.id);
    }
    return usersToAddIds;
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
                    onPressed: usersToAdd.isNotEmpty
                        ? () {
                            Navigator.of(context)
                                .pop(extractIdFrom(usersToAdd));
                          }
                        : null,
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
                        if (userFound != null &&
                            !usersToAdd.contains(userFound) &&
                            userFound.id != widget.authorId) {
                          userToAdd = userFound;
                          enableAddButton = true;
                        } else {
                          userToAdd = null;
                          enableAddButton = false;
                        }
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
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: isAddUserButtonEnabled()
                        ? () {
                            if (!usersToAdd.contains(userToAdd)) {
                              setState(() {
                                usersToAdd.add(userToAdd!);
                              });
                            }
                          }
                        : null,
                    child: Icon(Icons.add_circle_outline_sharp),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: usersToAdd.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: true,
                        onChanged: (value) {
                          setState(() {
                            usersToAdd.removeAt(index);
                            value = false;
                          });
                        },
                        title: Text(usersToAdd[index].email),
                      );
                    },
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
