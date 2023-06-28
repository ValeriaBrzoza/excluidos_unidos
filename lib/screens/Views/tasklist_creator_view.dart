import 'dart:async';

import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:excluidos_unidos/screens/Views/search_users_view.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/widgets/switch_list_tile.dart';
import 'package:intl/intl.dart';

class TaskListCreatorView extends StatefulWidget {
  const TaskListCreatorView({super.key});

  @override
  State<TaskListCreatorView> createState() => _TaskListCreatorViewState();
}

class _TaskListCreatorViewState extends State<TaskListCreatorView> {
  int index = 0;

  bool enableSaveButton = false;

  String name = "";

  bool isShared = false;

  bool isSupervised = false;

  List<String> usersId = [FirebaseAuth.instance.currentUser!.uid];

  bool tasksLimitDateRequired = false;

  DateTime? globalDeadLine;

  Timer? showSaveButtonTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //se llama cuando el boton desaparece
    showSaveButtonTimer?.cancel(); //cancela timer del boton, si existe
    super.dispose(); //es metodo de superclase
  }

  bool isSaveButtomEnabled() {
    return enableSaveButton;
  }

  void complete() {
    print(usersId);
    Navigator.of(context).pop(
      TaskList(
        name: name,
        usersIds: usersId, //como solucionamos esto?
        isShared: isShared,
        supervisorsIds: [FirebaseAuth.instance.currentUser!.uid],
        tasksLimitDateRequired: tasksLimitDateRequired,
        globalDeadline: globalDeadLine, //Agregar fecha de vencimiento
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
          height: 516,
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
                        //debe aparecer boton de guardar
                        showSaveButtonTimer?.cancel();
                        showSaveButtonTimer = Timer(
                            const Duration(milliseconds: 200),
                            () => setState(() => enableSaveButton = true));
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
                      //barrita swichiable propia
                      label: 'Compartir lista',
                      value: isShared,
                      onTap: isShared ? () {} : null,
                      description: 'Agregar Usuarios',
                      onChanged: (value) async {
                        setState(() {
                          isShared = value;
                        });
                        if (isShared) {
                          final List<String> users = await showDialog(
                              context: context,
                              builder: (context) => const SearchUsers());
                          setState(() {
                            usersId.addAll(users);
                          });
                        }
                      }),
                  CustomSwitchListTile(
                    //barrita swichiable propia
                    label: 'Lista supervisada',
                    value: isSupervised,
                    onTap: () {},
                    onChanged: isShared //si IsShared, te permite cambiar T y F
                        ? (value) {
                            setState(() {
                              isSupervised = value;
                            });
                          }
                        : null, //si no IsShared, no te deja cambiarla (gris deshabilitado)
                  ),
                  CustomSwitchListTile(
                    //barrita swichiable propia
                    label: 'Requerir fecha máxima para las tareas',
                    value: tasksLimitDateRequired,
                    onChanged: (value) {
                      setState(() {
                        tasksLimitDateRequired = value;
                      });
                    },
                  ),
                  CustomSwitchListTile(
                    //barrita swichiable propia
                    label: 'Fecha máxima global',
                    value: globalDeadLine != null,
                    description: globalDeadLine != null
                        ? DateFormat('dd MMMM y').format(globalDeadLine!)
                        : null,
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
