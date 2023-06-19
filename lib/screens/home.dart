import 'package:flutter/material.dart';
import 'package:prueba_01/screens/Views/lists_view.dart';
import 'package:prueba_01/screens/Views/settings_screen.dart';
import 'package:prueba_01/models/tasklist.dart';

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
    final themeColors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      //Botones de la Barra de navegacion
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        fixedColor: themeColors.secondary,
        backgroundColor: themeColors.primary,
        unselectedItemColor: themeColors.background,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Lists',
          ),
          BottomNavigationBarItem(
            //dibujos de abajo
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
    );
  }
}
