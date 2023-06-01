import 'tasklist.dart';

class DataProvider {
  List<TaskList> getLists() {
    return [
      TaskList(
        name: 'Lista1',
        usersIds: [],
        isShared: false,
        supervisorsIds: [],
        tasksLimitDateRequired: false,
        globalDeadline: null,
      ),
      TaskList(
        name: 'Lista2',
        usersIds: [],
        isShared: false,
        supervisorsIds: [],
        tasksLimitDateRequired: false,
        globalDeadline: null,
      ),
      TaskList(
        name: 'Compras',
        usersIds: [],
        isShared: false,
        supervisorsIds: [],
        tasksLimitDateRequired: false,
        globalDeadline: null,
      )
    ];
  }

  static final instance = DataProvider();
}
