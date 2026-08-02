import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';
import 'credits_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _languageNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '中文',
  };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final save = app.save;
    final colors = context.oneColors;
    final t = AppLocalizations.of(context);

    return BannerScaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          SwitchListTile(
            title: Text(t.music),
            value: save.music,
            activeThumbColor: colors.accent,
            onChanged: app.setMusic,
          ),
          SwitchListTile(
            title: Text(t.soundEffects),
            value: save.sfx,
            activeThumbColor: colors.accent,
            onChanged: app.setSfx,
          ),
          SwitchListTile(
            title: Text(t.haptics),
            value: save.haptics,
            activeThumbColor: colors.accent,
            onChanged: app.setHaptics,
          ),
          SwitchListTile(
            title: Text(t.reduceMotion),
            value: save.reduceMotion,
            activeThumbColor: colors.accent,
            onChanged: app.setReduceMotion,
          ),
          const Divider(),
          ListTile(
            title: Text(t.theme),
            subtitle: Text(_themeLabel(t, save.themeMode)),
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
                          title: Text(_themeLabel(t, mode)),
                          onTap: () => Navigator.pop(context, mode),
                        ),
                    ],
                  ),
                ),
              );
              if (next != null) await app.setThemeMode(next);
            },
          ),
          ListTile(
            title: Text(t.language),
            subtitle: Text(_languageNames[save.languageCode] ?? 'English'),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.text1),
            onTap: () async {
              final next = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: colors.bg1,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final code in _languageNames.keys)
                        ListTile(
                          title: Text(_languageNames[code]!),
                          onTap: () => Navigator.pop(context, code),
                        ),
                    ],
                  ),
                ),
              );
              if (next != null) await app.setLanguageCode(next);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(t.about),
            subtitle: Text(
              t.aboutSubtitle(GameConstants.appName),
              style: TextStyle(color: colors.text1),
            ),
          ),
          ListTile(
            title: Text(t.credits),
            subtitle: Text(
              t.creditsSubtitle,
              style: TextStyle(color: colors.text1, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: colors.text1),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreditsScreen(fromSettings: true),
                ),
              );
            },
          ),
          ListTile(
            title: Text(t.privacyPolicy),
            subtitle: Text(
              t.privacyPolicySubtitle,
              style: TextStyle(color: colors.text1, fontSize: 12),
            ),
            trailing: Icon(Icons.open_in_new_rounded, color: colors.text1),
            onTap: () => _openPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.parse(GameConstants.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text(GameConstants.privacyPolicyUrl)),
      );
    }
  }

  String _themeLabel(AppLocalizations t, String mode) {
    switch (mode) {
      case 'light':
        return t.themeLight;
      case 'system':
        return t.themeSystem;
      default:
        return t.themeDark;
    }
  }
}
