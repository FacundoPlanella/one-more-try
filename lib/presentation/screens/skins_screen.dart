import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/skin_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;
    final t = AppLocalizations.of(context);

    return BannerScaffold(
      appBar: AppBar(
        leading: WoodBackButton(tooltip: t.back),
        title: TitlePlate(text: t.skinsTitle),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: SkinCatalog.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final skin = SkinCatalog.all[index];
          final unlocked = save.unlockedSkins.contains(skin.id);
          final equipped = save.equippedSkin == skin.id;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: unlocked ? () => app.equipSkin(skin.id) : null,
            child: WoodPanel(
              highlighted: equipped,
              child: Row(
                children: [
                  SkinPreview(skin: skin),
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
                        if (skin.creatureName != null)
                          Text(
                            skin.creatureName!,
                            style: GoogleFonts.manrope(
                              color: colors.text1,
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          unlocked
                              ? (equipped ? t.equipped : t.unlocked)
                              : SkinUnlockHint.resolve(context, skin),
                          style: GoogleFonts.manrope(
                            color: colors.text1,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked)
                    Semantics(
                      label: SkinUnlockHint.resolve(context, skin),
                      child: Image.asset(
                        'assets/images/ui/indicador_skin_bloqueada.png',
                        width: 34,
                        height: 34,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
