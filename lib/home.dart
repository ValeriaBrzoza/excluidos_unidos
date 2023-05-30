import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$index Tareas'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.ac_unit_rounded),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) {
            setState(() {
              index = value;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            )
          ],
        ),
        body: ListView.builder(
          itemCount: 1000,
          itemBuilder: (context, index) =>
              ListTile(title: Text('$index Holaaa ')),
        ));
  }
}
