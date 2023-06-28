import 'package:excluidos_unidos/screens/Views/search_users_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/tasklist_creator_view.dart';
import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:excluidos_unidos/screens/Views/tasks_view.dart';
import 'package:excluidos_unidos/models/tasklist.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ListsView extends StatefulWidget {
  const ListsView({Key? key}) : super(key: key);

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  Stream<List<TaskList>> listsStream =
      DataProvider.instance.getLists(FirebaseAuth.instance.currentUser!.uid);
  bool _reversed = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: listsStream,
        builder: (context, snapshot) {
          final tasksList = snapshot.data ?? [];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Mis Listas'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              actions: [
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ListSearchDelegate(
                        listsStream: tasksList,
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _reversed = !_reversed;
                    });
                  },
                  icon: const Icon(Icons.sort),
                  tooltip: 'Ordenar',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final newList = await showDialog<TaskList>(
                  context: context,
                  builder: (context) => const TaskListCreatorView(),
                );

                if (newList == null) return;

                await DataProvider.instance.addList(newList);
              },
              child: const Icon(Icons.add),
            ),
            body: StreamBuilder<List<TaskList>>(
              stream: DataProvider.instance
                  .getLists(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final lists = snapshot.data!;
                  return TaskListListView(lists: lists, reversed: _reversed);
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          );
        });
  }
}

class ListSearchDelegate extends SearchDelegate {
  ListSearchDelegate({
    required this.listsStream,
  });

  final List<TaskList> listsStream;

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => close(context, null),
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = listsStream
        .where((taskList) =>
            taskList.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final taskList = searchResults[index];
        return ListTile(
          title: Text(taskList.name),
          onTap: () {
            query = taskList.name;
            close(context, null);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskListView(
                tasksList: taskList,
              ),
            ));
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final searchResults = listsStream
        .where((taskList) =>
            taskList.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final taskList = searchResults[index];
        return ListTile(
          title: Text(taskList.name),
          onTap: () {
            query = taskList.name;
            close(context, null);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskListView(
                tasksList: taskList,
              ),
            ));
          },
        );
      },
    );
  }
}

class TaskListListView extends StatelessWidget {
  const TaskListListView({
    Key? key,
    required this.lists,
    required this.reversed,
  }) : super(key: key);

  final List<TaskList> lists;
  final bool reversed;

  void showTaskList(TaskList list, BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TaskListView(
        tasksList: list,
      ),
    ));
  }

  Future<void> deleteList(String listId, BuildContext context) async {
    // Request confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content:
            const Text('¿Estás seguro de que quieres eliminar esta lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // If confirmed, delete task
    if (confirmed == true) {
      await DataProvider.instance.deleteList(listId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) {
        index = reversed ? index : (lists.length - 1 - index);
        final list = lists[index];
        final actionPane = ActionPane(
          extentRatio: 0.66,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                deleteList(list.id!, context);
              },
              label: 'Eliminar',
              backgroundColor: Colors.red,
              icon: Icons.clear,
            ),
            Visibility(
              visible: list.isShared,
              child: SlidableAction(
                onPressed: (context) async {
                  final List<String> newlyAddedUsers = await showDialog(
                    context: context,
                    builder: (context) => SearchUsers(),
                  );
                  //addUsersToList(list.Id!, newlyAddedUsers);  ---> falta hacer esta funcion
                },
                label: 'Añadir',
                backgroundColor: Colors.grey,
                icon: Icons.supervised_user_circle_rounded,
              ),
            )
          ],
        );

        return Slidable(
          key: Key(list.id!),
          startActionPane: actionPane,
          endActionPane: actionPane,
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(lists[index].isShared ? Icons.people : Icons.person),
            ),
            subtitle: lists[index].hasDeadline
                ? Text(DateFormat('dd/MM/yyyy')
                    .format(lists[index].globalDeadline!))
                : null,
            title: Text(lists[index].name),
            onTap: () {
              showTaskList(lists[index], context);
            },
          ),
        );
      },
    );
  }
}
