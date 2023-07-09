import 'package:excluidos_unidos/services/data_provider.dart';
import 'package:flutter/material.dart';

Future<List<ShareableUser>> showSearchUsersDialog(
  BuildContext context, {
  List<String>? excludeUsersIds,
  List<ShareableUser>? initialUsers,
}) async {
  final List<ShareableUser>? users = await showDialog(
    context: context,
    builder: (context) {
      return SearchUsersDialog(excludeUsers: excludeUsersIds, initialUsers: initialUsers);
    },
  );

  return users ?? initialUsers ?? [];
}

class SearchUsersDialog extends StatefulWidget {
  const SearchUsersDialog({super.key, required this.excludeUsers, required this.initialUsers});
  final List<String>? excludeUsers;
  final List<ShareableUser>? initialUsers;

  @override
  State<SearchUsersDialog> createState() => _SearchUsersDialogState();
}

class _SearchUsersDialogState extends State<SearchUsersDialog> {
  List<ShareableUser> usersToAdd = [];

  final textFieldController = TextEditingController();

  @override
  void initState() {
    if (widget.initialUsers != null) {
      usersToAdd.addAll(widget.initialUsers!);
    }

    super.initState();
  }

  void addUser(ShareableUser user) {
    setState(() {
      usersToAdd.add(user);
    });
  }

  // Usuario que se está bucando en base al mail ingresado
  ShareableUser? stagedUser;
  // Email del usuario que se está bucando
  String lastEmail = '';

  void emailTextFieldChanged(String email) async {
    // Settear el email del usuario que se está buscando y limpiar el usuario que se estaba bucando antes
    setState(() {
      lastEmail = email;
      stagedUser = null;
    });

    // Si el email es vacío, no hacer nada
    if (email.isEmpty) return;

    // Buscar el usuario por email
    final user = await DataProvider.instance.searchForUser(email.trim());

    // Si no se encontró el usuario no hacer nada
    if (user == null) return;
    // Si se encontró el usuario y el email cambió, no hacer nada
    if (user.email != lastEmail) return;
    // Si el usuario esta en la lista de usuarios a excluir, no hacer nada
    if (widget.excludeUsers?.contains(user.id) ?? false) return;
    // Si el usuario ya está en la lista de usuarios a agregar, no hacer nada
    if (usersToAdd.contains(user)) return;

    // Settear el usuario que se está buscando
    setState(() {
      stagedUser = user;
    });
  }

  void addStagedUser() {
    if (stagedUser != null) {
      addUser(stagedUser!);
      textFieldController.clear();
      emailTextFieldChanged('');
    }
  }

  void removeUser(ShareableUser user) {
    setState(() {
      usersToAdd.remove(user);
    });
  }

  void closeDialog() {
    Navigator.of(context).pop(usersToAdd);
  }

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
              title: const Text('Buscar usuarios'),
            ),
            bottomNavigationBar: BottomBar(usersToAdd: usersToAdd, closeDialog: closeDialog),
            body: DialogBody(
              stagedUser: stagedUser,
              usersToAdd: usersToAdd,
              addStagedUser: addStagedUser,
              removeUser: removeUser,
              emailTextFieldChanged: emailTextFieldChanged,
              textFieldController: textFieldController,
            ),
          ),
        ),
      ),
    );
  }
}

class DialogBody extends StatelessWidget {
  const DialogBody({
    super.key,
    required this.stagedUser,
    required this.usersToAdd,
    required this.addStagedUser,
    required this.removeUser,
    required this.emailTextFieldChanged,
    required this.textFieldController,
  });

  final ShareableUser? stagedUser;
  final List<ShareableUser> usersToAdd;
  final void Function() addStagedUser;
  final void Function(ShareableUser) removeUser;
  final void Function(String) emailTextFieldChanged;
  final TextEditingController textFieldController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            //recuadro de texto para el nombre de la lista
            onChanged: emailTextFieldChanged,
            controller: textFieldController,
            decoration: const InputDecoration(
              //visual del textfield
              labelText: 'Añadir usuario por email',
              filled: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: stagedUser != null ? addStagedUser : null,
            icon: const Icon(Icons.add_circle_outline_sharp),
            label: Text("Añadir ${stagedUser?.name ?? ''}"),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: usersToAdd.length,
            itemBuilder: (context, index) {
              return ListTile(
                trailing: IconButton(
                  onPressed: () => removeUser(usersToAdd[index]),
                  icon: const Icon(Icons.clear),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(usersToAdd[index].photoUrl),
                ),
                title: Text(usersToAdd[index].name),
                subtitle: Text(usersToAdd[index].email),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.usersToAdd,
    required this.closeDialog,
  });

  final List<ShareableUser> usersToAdd;
  final void Function() closeDialog;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: usersToAdd.isNotEmpty ? closeDialog : null,
            icon: const Icon(Icons.navigate_next),
            label: const Text("Agregar"),
          )
        ],
      ),
    );
  }
}
