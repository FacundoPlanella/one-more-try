import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/perk_catalog.dart';
import '../../domain/catalogs/skin_catalog.dart';
import '../../domain/entities/perk.dart';
import '../../domain/entities/skin.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/common_widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;
    final t = AppLocalizations.of(context);
    final shopSkins = SkinCatalog.all.where((s) => s.isShopExclusive).toList();

    return BannerScaffold(
      appBar: AppBar(
        title: Text(t.shopTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: CoinLabel(
                amount: save.coins,
                iconSize: 18,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colors.text0,
                ),
              ),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            t.sectionSkins,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 10),
          for (final skin in shopSkins) ...[
            _ShopSkinTile(skin: skin),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          Text(
            t.sectionPerks,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 10),
          for (final perk in PerkCatalog.all) ...[
            _ShopPerkTile(perk: perk),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ShopSkinTile extends StatelessWidget {
  const _ShopSkinTile({required this.skin});

  final SkinDef skin;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;
    final t = AppLocalizations.of(context);
    final owned = save.unlockedSkins.contains(skin.id);
    final equipped = save.equippedSkin == skin.id;
    final afford = save.coins >= skin.priceCoins!;

    return Container(
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
          SkinPreview(skin: skin),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RarityDiamond(color: skin.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      skin.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                if (skin.creatureName != null)
                  Text(
                    skin.creatureName!,
                    style: GoogleFonts.manrope(color: colors.text1, fontSize: 12),
                  ),
                owned
                    ? Text(
                        equipped ? t.equipped : t.owned,
                        style: GoogleFonts.manrope(color: colors.text1, fontSize: 13),
                      )
                    : CoinLabel(
                        amount: skin.priceCoins!,
                        iconSize: 13,
                        style: GoogleFonts.manrope(color: colors.text1, fontSize: 13),
                      ),
              ],
            ),
          ),
          if (owned)
            TextButton(
              onPressed: equipped ? null : () => app.equipSkin(skin.id),
              child: Text(equipped ? t.equipped : t.equip),
            )
          else
            FilledButton(
              onPressed: afford ? () => app.purchaseSkin(skin.id) : null,
              child: Text(t.buy),
            ),
        ],
      ),
    );
  }
}

class _ShopPerkTile extends StatelessWidget {
  const _ShopPerkTile({required this.perk});

  final PerkDef perk;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final colors = context.oneColors;
    final save = app.save;
    final t = AppLocalizations.of(context);
    final owned = save.purchasedPerks.contains(perk.id);
    final afford = save.coins >= perk.priceCoins;
    final name = PerkLabels.name(context, perk.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lane, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Text(
                  PerkLabels.description(context, perk.id),
                  style: GoogleFonts.manrope(color: colors.text1, fontSize: 13),
                ),
                if (owned)
                  Text(
                    t.perkActiveLabel,
                    style: GoogleFonts.manrope(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )
                else
                  CoinLabel(
                    amount: perk.priceCoins,
                    iconSize: 13,
                    style: GoogleFonts.manrope(color: colors.text1, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (owned)
            Icon(Icons.check_circle_rounded, color: colors.success)
          else
            FilledButton(
              onPressed: afford
                  ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await app.purchasePerk(perk.id);
                      if (ok) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(t.perkPurchasedSnackbar(name))),
                        );
                      }
                    }
                  : null,
              child: Text(t.buy),
            ),
        ],
      ),
    );
  }
}
