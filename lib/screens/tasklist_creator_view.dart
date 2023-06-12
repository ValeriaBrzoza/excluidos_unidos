import 'dart:async';

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
    //se llama cuando el boton desaparece
    showSaveButtonTimer?.cancel(); //cancela timer del boton, si existe
    super.dispose(); //es metodo de superclase
  }

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
          height: 376 + (showSaveButton ? 70 : 0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Crear lista de tareas'),
            ),
            //
            floatingActionButton: showSaveButton //boton de continuar
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
                shrinkWrap: true, //list view no ocupe todo el alto
                children: [
                  TextField(
                    //recuadro de texto para el nombre de la lista
                    onChanged: (value) {
                      if (value != "") {
                        //debe aparecer boton de guardar
                        showSaveButtonTimer?.cancel();
                        showSaveButtonTimer = Timer(const Duration(milliseconds: 200), () => setState(() => showSaveButton = true));
                        setState(() {
                          name = value; //guarda nombre
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
                    description: "Juan Carlos, Pepito y cinco más",
                    onChanged: (value) {
                      setState(() {
                        isShared = value;
                      });
                    },
                  ),
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
                    label: 'Requerir fecha máxima global',
                    value: globalDeadLine,
                    description: "25 de mayo de 2024",
                    onChanged: tasksLimitDateRequired //si fecha limite de tareas
                        ? (value) {
                            setState(() {
                              //te permite cambiar T y F
                              globalDeadLine = value;
                            });
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
