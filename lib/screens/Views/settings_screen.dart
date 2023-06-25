import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/ValeriaBrzoza/excluidos_unidos');

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _toggle = Get.isDarkMode;
  @override
  Widget build(BuildContext context) {
    const themeData = SettingsThemeData(settingsListBackground: Colors.transparent, settingsSectionBackground: Colors.transparent);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: SettingsList(
        applicationType: ApplicationType.material,
        platform: DevicePlatform.android,
        lightTheme: themeData,
        darkTheme: themeData,
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              if (user == null)
                SettingsTile.navigation(
                  title: const Text('Iniciar sesión con Google'),
                  leading: const Icon(Icons.no_accounts),
                  description: const Text('Estás como usuario invitado'),
                  onPressed: (context) {
                    if (kIsWeb) {
                      FirebaseAuth.instance.signInWithRedirect(GoogleAuthProvider());
                    } else {
                      FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
                    }
                  },
                ),
              if (user != null)
                SettingsTile.navigation(
                  title: Text(user.displayName ?? 'Usuario'),
                  leading: const Icon(Icons.account_circle),
                  description: user.email != null ? Text(user.email!) : null,
                ),
              if (user != null)
                SettingsTile(
                  title: const Text('Cerrar sesión'),
                  leading: const Icon(Icons.logout),
                  onPressed: (_) async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/');
                  },
                ),
              SettingsTile.switchTile(
                onToggle: (_) {
                  _toggle
                      ? Get.changeTheme(ThemeData(
                          useMaterial3: true,
                          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C00CE), secondary: const Color(0xFFFF7A00)),
                        ))
                      : Get.changeTheme(ThemeData.dark(useMaterial3: true));
                  setState(() {
                    _toggle = _;
                  });
                },
                initialValue: _toggle,
                leading: const Icon(Icons.format_paint),
                title: const Text('Modo Oscuro'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Acerca de'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.webhook),
                title: const Text('Repositorio GitHub'),
                onPressed: (_) {
                  launchUrl(_url);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
