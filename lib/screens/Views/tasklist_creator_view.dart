import 'dart:async';
import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/screens/Views/search_users_dialog.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/widgets/switch_list_tile.dart';
import 'package:intl/intl.dart';

import '../../services/data_provider.dart';

class TaskListCreatorView extends StatefulWidget {
  const TaskListCreatorView({super.key});

  @override
  State<TaskListCreatorView> createState() => _TaskListCreatorViewState();
}

class _TaskListCreatorViewState extends State<TaskListCreatorView> {
  int index = 0;

  bool enableSaveButton = false;

  String name = "";

  bool shared = false;

  bool isSupervised = false;

  List<ShareableUser> shareWith = [];

  bool tasksLimitDateRequired = false;

  DateTime? globalDeadLine;

  Timer? showSaveButtonTimer;

  List<ShareableUser> selectedUsers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //se llama cuando el botón desaparece
    showSaveButtonTimer?.cancel(); //cancela timer del botón, si existe
    super.dispose(); //es método de superclase
  }

  bool isSaveButtomEnabled() {
    return enableSaveButton;
  }

  void complete() {
    final users = [DataProvider.instance.currentUser.uid];

    if (shared) {
      users.addAll(shareWith.map((user) => user.id).toList());
    }

    Navigator.of(context).pop(
      TaskList(
        name: name,
        usersIds: users,
        isShared: shared,
        tasksLimitDateRequired: tasksLimitDateRequired,
        globalDeadline: globalDeadLine, // Agregar fecha de vencimiento
      ),
    );
  }

  void showSetGlobalDeadlineDialog() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    setState(() {
      globalDeadLine = date;
    });
  }

  void enableSharing(bool value) async {
    if (!value) {
      return setState(() {
        shared = false;
      });
    }

    if (shareWith.isEmpty) {
      final users = await showSearchUsersDialog(
        context,
        excludeUsersIds: [DataProvider.instance.currentUser.uid],
        initialUsers: shareWith,
      );

      if (users.isEmpty) return;

      return setState(() {
        shareWith = users;
        shared = true;
      });
    }

    setState(() {
      shared = true;
    });
  }

  void showShare() async {
    final users = await showSearchUsersDialog(
      context,
      excludeUsersIds: [DataProvider.instance.currentUser.uid],
      initialUsers: shareWith,
    );

    setState(() {
      shareWith = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      //cartel flotante, centrado
      child: ClipRRect(
        //recorta bordes para que sea redondeado
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          //conteniner que se agrega para el botón de guardar
          duration: const Duration(milliseconds: 200),
          height: 415,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Crear lista de tareas'),
            ),
            //
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              //isSaveButtomEnabled() ? () => {} : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSaveButtomEnabled() ? complete : null,
                    icon: const Icon(Icons.navigate_next),
                    label: const Text("Crear"),
                  )
                ],
              ),
            ),
            //
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                shrinkWrap: true, //list view no ocupe todo el alto
                children: [
                  TextField(
                    //recuadro de texto para el nombre de la lista
                    onChanged: (value) {
                      if (value != "") {
                        //debe aparecer botón de guardar
                        showSaveButtonTimer?.cancel();
                        showSaveButtonTimer = Timer(const Duration(milliseconds: 200), () => setState(() => enableSaveButton = true));
                        setState(() {
                          name = value; //guarda nombre
                        });
                      } else {
                        showSaveButtonTimer?.cancel();
                        setState(() {
                          name = value;
                          enableSaveButton = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      //visual del textfield
                      labelText: 'Nombre de la lista',
                      filled: true,
                    ),
                  ),
                  CustomSwitchListTile(
                    //barrita switchable propia
                    label: 'Compartir lista',
                    value: shared,
                    onTap: shared ? showShare : null,
                    description: shareWith.isEmpty ? 'Agregar Usuarios' : shareWith.map((user) => user.name).join(', '),
                    onChanged: enableSharing,
                  ),
                  CustomSwitchListTile(
                    //barrita switchable propia
                    label: 'Requerir fecha máxima para las tareas',
                    value: tasksLimitDateRequired,
                    onChanged: (value) {
                      setState(() {
                        tasksLimitDateRequired = value;
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    //barrita switchable propia
                    label: 'Fecha máxima global',
                    value: globalDeadLine != null,
                    description: globalDeadLine != null ? DateFormat('dd MMMM y').format(globalDeadLine!) : null,
                    onChanged: tasksLimitDateRequired //si fecha limite de tareas
                        ? (value) {
                            if (value == false) {
                              setState(() {
                                globalDeadLine = null;
                              });
                            } else {
                              showSetGlobalDeadlineDialog();
                            }
                          }
                        : null, //si no fecha limite por tarea, no te deja cambiarla (gris deshabilitado)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
