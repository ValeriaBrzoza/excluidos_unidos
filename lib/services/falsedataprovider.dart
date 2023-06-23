import 'package:excluidos_unidos/models/tasks.dart';

import '../models/tasklist.dart';

class DataProvider {
  List<TaskList> getLists() {
    var lista = TaskList(
      name: 'Lista',
      usersIds: [],
      isShared: false,
      supervisorsIds: [],
      tasksLimitDateRequired: false,
      globalDeadline: null,
    );
    lista.addTask(Task(title: "Comprar pan"));

    return [
      lista,
    ];
  }

  static final instance = DataProvider();
}
