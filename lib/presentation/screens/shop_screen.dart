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
    final save = app.save;
    final t = AppLocalizations.of(context);
    final shopSkins = SkinCatalog.all.where((s) => s.isShopExclusive).toList();

    return BannerScaffold(
      appBar: AppBar(
        leading: WoodBackButton(tooltip: t.back),
        title: TitlePlate(text: t.shopTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: CoinLabel(
                amount: save.coins,
                iconSize: 16,
                width: 132,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: woodPlateTextPrimary,
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
      decoration: equipped
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.55),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: AspectRatio(
        // Proporción original de tarjeta_skin_tienda.png — no se deforma.
        aspectRatio: 2172 / 724,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/ui/tarjeta_skin_tienda.png',
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                children: [
                  SkinPreview(skin: skin, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RarityDiamond(color: skin.color, size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                skin.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: woodPlateTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (skin.creatureName != null)
                          Text(
                            skin.creatureName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: woodPlateTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        owned
                            ? Text(
                                equipped ? t.equipped : t.owned,
                                style: GoogleFonts.manrope(
                                  color: woodPlateTextSecondary,
                                  fontSize: 12,
                                ),
                              )
                            : CoinLabel(
                                amount: skin.priceCoins!,
                                iconSize: 13,
                                plated: false,
                                style: GoogleFonts.manrope(
                                  color: woodPlateTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (equipped)
                    Semantics(
                      label: t.equipped,
                      child: Image.asset(
                        'assets/images/ui/indicador_skin_equipada.png',
                        width: 40,
                        height: 40,
                      ),
                    )
                  else if (owned)
                    SecondaryButton(
                      label: t.equip,
                      width: 104,
                      onPressed: () => app.equipSkin(skin.id),
                    )
                  else
                    PurchaseButton(
                      label: t.buy,
                      width: 104,
                      onPressed: afford
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final confirmed = await showConfirmationPanel(
                                context,
                                title: t.confirmPurchaseTitle,
                                description: t.confirmPurchaseSkinMessage(
                                  skin.name,
                                  skin.priceCoins!,
                                ),
                                confirmLabel: t.buy,
                                cancelLabel: t.cancel,
                              );
                              if (!confirmed) return;
                              final ok = await app.purchaseSkin(skin.id);
                              if (ok) {
                                showWoodSnackBar(
                                  messenger,
                                  message: t.skinPurchasedSnackbar(skin.name),
                                  iconAsset: 'assets/images/ui/icono_exito.png',
                                );
                              } else {
                                showWoodSnackBar(
                                  messenger,
                                  message: t.purchaseFailedSnackbar,
                                  iconAsset: 'assets/images/ui/icono_error.png',
                                );
                              }
                            }
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
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

    return WoodPanel(
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
                    iconSize: 14,
                    plated: false,
                    style: GoogleFonts.manrope(color: colors.text1, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (owned)
            Icon(Icons.check_circle_rounded, color: colors.success)
          else
            PurchaseButton(
              label: t.buy,
              onPressed: afford
                  ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await app.purchasePerk(perk.id);
                      if (ok) {
                        showWoodSnackBar(
                          messenger,
                          message: t.perkPurchasedSnackbar(name),
                          iconAsset: 'assets/images/ui/icono_exito.png',
                        );
                      } else {
                        showWoodSnackBar(
                          messenger,
                          message: t.purchaseFailedSnackbar,
                          iconAsset: 'assets/images/ui/icono_error.png',
                        );
                      }
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}
