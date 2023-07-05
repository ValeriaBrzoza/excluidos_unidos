import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:flutter/material.dart';

class AssignUser extends StatefulWidget {
  const AssignUser({super.key, required this.usersIds, required this.listId});
  final List<String> usersIds;
  final String listId;
  @override
  State<AssignUser> createState() => _AssignUserState();
}

class _AssignUserState extends State<AssignUser> {
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
                title: const Text("Asignar Usuario"),
              ),
              body: ListView(
                children: [
                  FutureBuilder<List<ShareableUser>>(
                    future:
                        DataProvider.instance.getUsersFromList(widget.listId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final users = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.photoUrl),
                              ),
                              onTap: () {
                                Navigator.of(context).pop(user.id);
                              },
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
