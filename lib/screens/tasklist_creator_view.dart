import 'dart:async';

import 'package:adaptative_modals/adaptative_modals.dart';
import 'package:flutter/material.dart';
import 'package:prueba_01/widgets/switch_list_tile.dart';

class TaskListCreatorView extends StatefulWidget {
  const TaskListCreatorView({super.key});

  @override
  State<TaskListCreatorView> createState() => _TaskListCreatorViewState();
}

class _TaskListCreatorViewState extends State<TaskListCreatorView> {
  int index = 0;

  bool showSaveButton = false;

  String name = "";

  bool isShared = false;

  bool isSupervised = false;

  bool tasksLimitDateRequired = false;

  bool globalDeadLine = false;

  Timer? showSaveButtonTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    showSaveButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 376 + (showSaveButton ? 70 : 0),
          child: Scaffold(
            appBar: AdaptativeModalAppBarWrapper(
              appbar: AppBar(
                title: const Text('Crear lista de tareas'),
              ),
            ),
            //
            floatingActionButton: showSaveButton
                ? FloatingActionButton.extended(
                    label: const Text("Continuar"),
                    onPressed: () {},
                    icon: const Icon(Icons.navigate_next),
                  )
                : null,
            //
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    onChanged: (value) {
                      if (value != "") {
                        showSaveButtonTimer?.cancel();
                        showSaveButtonTimer = Timer(
                            const Duration(milliseconds: 200),
                            () => setState(() => showSaveButton = true));
                        setState(() {
                          name = value;
                        });
                      } else {
                        showSaveButtonTimer?.cancel();
                        setState(() {
                          name = value;
                          showSaveButton = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la lista',
                      filled: true,
                    ),
                  ),
                  CustomSwitchListTile(
                    label: 'Compartir lista',
                    value: isShared,
                    onTap: isShared ? () {} : null,
                    description: "Juan Carlos, Pepito y cinco más",
                    onChanged: (value) {
                      setState(() {
                        isShared = value;
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    label: 'Lista supervisada',
                    value: isSupervised,
                    onTap: () {},
                    onChanged: isShared
                        ? (value) {
                            setState(() {
                              isSupervised = value;
                            });
                          }
                        : null,
                  ),
                  CustomSwitchListTile(
                    label: 'Requerir fecha máxima para las tareas',
                    value: tasksLimitDateRequired,
                    onChanged: (value) {
                      setState(() {
                        tasksLimitDateRequired = value;
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    label: 'Requerir fecha máxima global',
                    value: globalDeadLine,
                    description: "25 de mayo de 2024",
                    onChanged: tasksLimitDateRequired
                        ? (value) {
                            setState(() {
                              globalDeadLine = value;
                            });
                          }
                        : null,
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
