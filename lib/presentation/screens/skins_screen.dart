import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/skin_catalog.dart';
import '../controllers/app_controller.dart';
import '../widgets/common_widgets.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;

    return BannerScaffold(
      appBar: AppBar(title: const Text('Skins')),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: SkinCatalog.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final skin = SkinCatalog.all[index];
          final unlocked = save.unlockedSkins.contains(skin.id);
          final equipped = save.equippedSkin == skin.id;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: unlocked ? () => app.equipSkin(skin.id) : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.bg1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: equipped ? colors.accent : colors.lane,
                  width: equipped ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: skin.ghost
                          ? skin.color.withValues(alpha: 0.5)
                          : skin.color,
                      border: skin.secondary != null
                          ? Border.all(color: skin.secondary!, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skin.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          unlocked ? (equipped ? 'Equipped' : 'Unlocked') : skin.unlockHint,
                          style: GoogleFonts.manrope(
                            color: colors.text1,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked)
                    Icon(Icons.lock_outline_rounded, color: colors.text1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
