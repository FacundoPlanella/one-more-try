import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../domain/catalogs/skin_catalog.dart';
import '../../domain/entities/skin.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/catalog_skin_card.dart';
import '../widgets/common_widgets.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final save = app.save;
    final t = AppLocalizations.of(context);
    final d = context.responsive;

    return BannerScaffold(
      appBar: GameAppBar(
        title: t.skinsTitle,
        backTooltip: t.back,
        height: d.appBarHeight,
      ),
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_skins.png',
      ),
      child: ListView.separated(
        padding: CatalogListCardMetrics.listPadding(context),
        itemCount: SkinCatalog.all.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: CatalogListCardMetrics.listSeparator(context)),
        itemBuilder: (context, index) {
          final skin = SkinCatalog.all[index];
          final unlocked = save.unlockedSkins.contains(skin.id);
          final equipped = save.equippedSkin == skin.id;
          return _SkinCard(
            skin: skin,
            unlocked: unlocked,
            equipped: equipped,
            t: t,
            onTap: unlocked ? () => app.equipSkin(skin.id) : null,
          );
        },
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.unlocked,
    required this.equipped,
    required this.t,
    required this.onTap,
  });

  final SkinDef skin;
  final bool unlocked;
  final bool equipped;
  final AppLocalizations t;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusLine = unlocked
        ? (equipped ? t.equipped : t.unlocked)
        : SkinUnlockHint.resolve(context, skin);

    Widget action;
    if (equipped) {
      action = CatalogSkinEquippedBadge(semanticLabel: t.equipped);
    } else if (!unlocked) {
      action = CatalogSkinLockedBadge(semanticLabel: statusLine);
    } else {
      action = const SizedBox.shrink();
    }

    return CatalogSkinCard(
      skin: skin,
      equipped: equipped,
      onTap: onTap,
      secondaryLine: skin.creatureName,
      statusLine: statusLine,
      action: action,
    );
  }
}
