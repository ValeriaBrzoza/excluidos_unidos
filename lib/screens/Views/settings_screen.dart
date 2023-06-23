import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';


final Uri _url = Uri.parse('https://github.com');

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _toggle = Get.isDarkMode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Account'),
                leading: const Icon(Icons.account_box),
                description: const Text('Account Settings'),
                // onPressed: (context) {
                //   Navigation.navigateTo(
                //     context: context,
                //     screen: CrossPlatformSettingsScreen(),
                //     style: NavigationRouteStyle.material,
                //   );
                // },
              ),
              SettingsTile.switchTile(
              onToggle: (_) {
                _toggle ? Get.changeTheme(ThemeData(useMaterial3: true,
                          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C00CE),
                          secondary: const Color(0xFFFF7A00)),))
                    : Get.changeTheme(ThemeData.dark(useMaterial3: true));
                setState(() {
                  _toggle = _;
                  
                  });              
                  },
                  
              initialValue: _toggle,
              leading: const Icon(Icons.format_paint),
              title: const Text('Dark Theme'),
            ),
            
            ],
          ),
          
          SettingsSection(
            title: const Text('About'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.webhook),
                title: const Text('Github Repository'),
                onPressed: (_) {launchUrl(_url);},
              ),
            ],
          ),
        ],
      ),
    );
  }
}