import 'dart:async';

import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/models/tasks.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCreatorView extends StatefulWidget {
  const TaskCreatorView({super.key, required this.tasksList});
  final TaskList tasksList;

  @override
  State<TaskCreatorView> createState() => _TaskCreatorViewState();
}

class _TaskCreatorViewState extends State<TaskCreatorView> {
  int index = 0;
  bool enableSaveButton = false;

  String name = "";
  DateTime? deadline;

  bool get canSave {
    if (widget.tasksList.tasksLimitDateRequired) {
      return name != '' && deadline != null;
    } else {
      return name != '';
    }
  }

  Future<void> createTask() {
    Navigator.of(context).pop();
    return DataProvider.instance.addTaskToTaskList(
      widget.tasksList.id!,
      Task(
        title: name,
        deadline: deadline,
        assignedUser: null,
        completed: false,
      ),
    );
  }

  //TODO: cambiar los números "mágicos" por varibles/constantes/etc.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      //cartel flotante, centrado
      child: ClipRRect(
        //recorta bordes para que sea redondeado
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          //conteniner que se agrega para el boton de guardar
          duration: const Duration(milliseconds: 200),
          height: widget.tasksList.tasksLimitDateRequired ? 240 : 206,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Agregar tarea'),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              //isSaveButtomEnabled() ? () => {} : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: canSave ? createTask : null,
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
                      setState(() {
                        name = value;
                        enableSaveButton = value != '';
                      });
                    },
                    decoration: const InputDecoration(
                      //visual del textfield
                      labelText: 'Nombre de la lista',
                      filled: true,
                    ),
                  ),
                  if (widget.tasksList.tasksLimitDateRequired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(deadline != null ? DateFormat('dd MMMM y').format(deadline!) : 'Fecha'),
                        IconButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: widget.tasksList.globalDeadline ?? DateTime.now().add(const Duration(days: 365 * 10)),
                            );
                            setState(() {
                              deadline = date;
                            });
                          },
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ],
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
