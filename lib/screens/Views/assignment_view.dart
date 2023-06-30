import 'package:flutter/material.dart';
import '../../models/tasklist.dart';

class AssignUser extends StatefulWidget {
  const AssignUser({super.key, required this.tasksList});
  final TaskList tasksList;

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
                title: const Text("Asignar usuario"),
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(10),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          )),
    );
  }
}
