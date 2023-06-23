import 'package:flutter/material.dart';
import 'package:excluidos_unidos/screens/Views/lists_view.dart';
import 'package:excluidos_unidos/screens/Views/settings_screen.dart';
import 'package:excluidos_unidos/models/tasklist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskList> listas = [];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ListsView(),
      const SettingsView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      //Botones de la Barra de navegacion
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'My Lists',
          ),
          NavigationDestination(
            //dibujos de abajo
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
    );
  }
}
