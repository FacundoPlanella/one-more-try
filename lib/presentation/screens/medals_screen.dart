import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/progression_catalogs.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';

class MedalsScreen extends StatelessWidget {
  const MedalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = context.watch<AppController>().save;
    final colors = context.oneColors;

    return BannerScaffold(
      appBar: AppBar(title: const Text('Medals & Titles')),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Title: ${_titleName(save.titleId)}',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 16),
          ...MedalCatalog.all.map((medal) {
            final unlocked = save.medals.contains(medal.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.lane),
                ),
                child: Row(
                  children: [
                    Icon(
                      unlocked
                          ? Icons.workspace_premium_rounded
                          : Icons.lock_outline_rounded,
                      color: unlocked ? colors.accent : colors.text1,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medal.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: unlocked ? colors.text0 : colors.text1,
                            ),
                          ),
                          Text(
                            medal.description,
                            style: GoogleFonts.manrope(
                              color: colors.text1,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _titleName(String id) {
    final match = TitleCatalog.all.where((t) => t.id == id);
    return match.isEmpty ? 'Novice' : match.first.name;
  }
}
