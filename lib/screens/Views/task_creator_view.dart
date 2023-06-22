import 'dart:async';

import 'package:excluidos_unidos/models/tasks.dart';
import 'package:flutter/material.dart';

class TaskCreatorView extends StatefulWidget {
  const TaskCreatorView({super.key});

  @override
  State<TaskCreatorView> createState() => _TaskCreatorViewState();
}

class _TaskCreatorViewState extends State<TaskCreatorView> {
  int index = 0;
  DatePickerEntryMode? fechaMaxima;
  bool enableSaveButton = false;

  String name = "";

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
          height: 280,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Agregar tarea'),
            ),
            //
            floatingActionButton: FloatingActionButton.extended(
              label: const Text("Crear"),
              onPressed: isSaveButtomEnabled()
                  ? () => {Navigator.of(context).pop(Task(title: name))}
                  : null,
              icon: const Icon(Icons.navigate_next),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fecha'),
                      IconButton(
                        onPressed: () {
                          showDatePicker(
                              onDatePickerModeChange: (value) {
                                fechaMaxima = value;
                              },
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2024));
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
