import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final save = app.save;
    final colors = context.oneColors;

    return BannerScaffold(
      appBar: AppBar(title: const Text('Settings')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          SwitchListTile(
            title: const Text('Music'),
            value: save.music,
            activeThumbColor: colors.accent,
            onChanged: app.setMusic,
          ),
          SwitchListTile(
            title: const Text('Sound effects'),
            value: save.sfx,
            activeThumbColor: colors.accent,
            onChanged: app.setSfx,
          ),
          SwitchListTile(
            title: const Text('Haptics'),
            value: save.haptics,
            activeThumbColor: colors.accent,
            onChanged: app.setHaptics,
          ),
          SwitchListTile(
            title: const Text('Reduce motion'),
            value: save.reduceMotion,
            activeThumbColor: colors.accent,
            onChanged: app.setReduceMotion,
          ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(save.themeMode)),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.text1),
            onTap: () async {
              final next = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: colors.bg1,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final mode in ['dark', 'light', 'system'])
                        ListTile(
                          title: Text(_themeLabel(mode)),
                          onTap: () => Navigator.pop(context, mode),
                        ),
                    ],
                  ),
                ),
              );
              if (next != null) await app.setThemeMode(next);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: Text(
              '${GameConstants.appName}\nOffline · Banner ads only · v1.0.0',
              style: TextStyle(color: colors.text1),
            ),
          ),
          ListTile(
            title: const Text('Privacy'),
            subtitle: Text(
              'Progress is stored only on this device. '
              'AdMob may collect data per Google policy. '
              'Replace this text with your privacy policy URL before release.',
              style: TextStyle(color: colors.text1, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'system':
        return 'System';
      default:
        return 'Dark';
    }
  }
}
