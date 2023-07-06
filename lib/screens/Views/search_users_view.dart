import 'dart:async';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/services/data_provider.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers(
      {super.key, required this.authorId, required this.usersToAdd});

  final String authorId;
  final List<ShareableUser> usersToAdd;

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  ShareableUser? userToAdd;

  Timer? showAddButtonTimer;

  bool get isAddUserButtonEnabled {
    return userToAdd != null;
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
                    onPressed: widget.usersToAdd.isNotEmpty
                        ? () {
                            Navigator.of(context).pop(widget.usersToAdd);
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    //recuadro de texto para el nombre de la lista
                    onChanged: (email) async {
                      final userFound = await DataProvider.instance
                          .searchForUser(email.trim());
                      setState(
                        () {
                          if (userFound != null &&
                              !widget.usersToAdd.contains(userFound) &&
                              userFound.id != widget.authorId) {
                            userToAdd = userFound;
                          } else {
                            userToAdd = null;
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: isAddUserButtonEnabled
                        ? () {
                            if (!widget.usersToAdd.contains(userToAdd)) {
                              setState(() {
                                widget.usersToAdd.add(userToAdd!);
                              });
                            }
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    label: Text("Añadir ${userToAdd?.name ?? ''}"),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.usersToAdd.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              widget.usersToAdd.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.usersToAdd[index].photoUrl),
                        ),
                        title: Text(widget.usersToAdd[index].name),
                        subtitle: Text(widget.usersToAdd[index].email),
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
