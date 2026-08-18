import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/catalogs/perk_catalog.dart';
import '../../domain/catalogs/skin_catalog.dart';
import '../../domain/entities/perk.dart';
import '../../domain/entities/skin.dart';
import '../../l10n/generated/app_localizations.dart';
import '../controllers/app_controller.dart';
import '../widgets/catalog_labels.dart';
import '../widgets/catalog_skin_card.dart';
import '../widgets/common_widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final save = app.save;
    final t = AppLocalizations.of(context);
    final shopSkins = SkinCatalog.all.where((s) => s.isShopExclusive).toList();
    final d = context.responsive;

    return BannerScaffold(
      appBar: GameAppBar(
        title: t.shopTitle,
        backTooltip: t.back,
        height: d.appBarHeight,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: d.scaledSize(8)),
            child: Center(
              child: CoinLabel(
                amount: save.coins,
                iconSize: d.scaledSize(18, min: 16),
                width: d.scaledSize(148, min: 132),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: d.scaledFont(16, min: 15),
                  color: woodPlateTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      background: const ScreenBackground(
        'assets/images/backgrounds/fondo_skins.png',
      ),
      child: ListView(
        padding: CatalogListCardMetrics.listPadding(context),
        children: [
          Text(
            t.sectionSkins,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: d.scaledFont(18, min: 16),
            ),
          ),
          SizedBox(height: d.scaledSize(10)),
          for (final skin in shopSkins) ...[
            _ShopSkinTile(skin: skin),
            SizedBox(height: CatalogListCardMetrics.listSeparator(context)),
          ],
          SizedBox(height: d.scaledSize(18)),
          Text(
            t.sectionPerks,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: d.scaledFont(18, min: 16),
            ),
          ),
          SizedBox(height: d.scaledSize(10)),
          for (final perk in PerkCatalog.all) ...[
            _ShopPerkTile(perk: perk),
            SizedBox(height: CatalogListCardMetrics.listSeparator(context)),
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
    final save = app.save;
    final t = AppLocalizations.of(context);
    final owned = save.unlockedSkins.contains(skin.id);
    final equipped = save.equippedSkin == skin.id;
    final afford = save.coins >= skin.priceCoins!;
    final d = context.responsive;
    final cardWidth = CatalogListCardMetrics.widthOf(context);
    final cardHeight = CatalogListCardMetrics.heightOf(context, cardWidth);
    final cardPadding = CatalogListCardMetrics.contentPadding(cardHeight);
    final preview = CatalogListCardMetrics.previewSize(cardHeight, cardPadding);
    final actionWidth = CatalogListCardMetrics.purchaseButtonWidth(
      cardWidth,
      cardHeight,
      cardPadding,
      preview,
    );
    final actionMaxH = cardHeight - cardPadding.vertical;

    Widget action;
    if (equipped) {
      action = CatalogSkinEquippedBadge(semanticLabel: t.equipped);
    } else if (owned) {
      action = SecondaryButton(
        label: t.equip,
        width: actionWidth,
        onPressed: () => app.equipSkin(skin.id),
      );
    } else {
      action = PurchaseButton(
        label: t.buy,
        width: actionWidth,
        maxHeight: actionMaxH,
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
      );
    }

    Widget? statusWidget;
    String statusLine = '';
    if (owned) {
      statusLine = equipped ? t.equipped : t.owned;
    } else {
      statusWidget = CoinLabel(
        amount: skin.priceCoins!,
        iconSize: d.scaledSize(16, min: 14),
        plated: false,
        style: GoogleFonts.manrope(
          color: woodPlateTextSecondary,
          fontSize: d.scaledFont(13, min: 12),
        ),
      );
    }

    return CatalogSkinCard(
      skin: skin,
      equipped: equipped,
      secondaryLine: skin.creatureName,
      statusLine: statusLine,
      statusWidget: statusWidget,
      action: action,
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
    final d = context.responsive;
    final cardWidth = CatalogListCardMetrics.widthOf(context);
    final actionWidth = d.scaledSize(112, min: 96).clamp(96.0, cardWidth * 0.22);

    return WoodPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: d.scaledFont(18, min: 16),
                  ),
                ),
                SizedBox(height: d.scaledSize(4)),
                Text(
                  PerkLabels.description(context, perk.id),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: colors.text1,
                    fontSize: d.scaledFont(13, min: 13),
                  ),
                ),
                SizedBox(height: d.scaledSize(4)),
                if (owned)
                  Text(
                    t.perkActiveLabel,
                    style: GoogleFonts.manrope(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: d.scaledFont(13, min: 13),
                    ),
                  )
                else
                  CoinLabel(
                    amount: perk.priceCoins,
                    iconSize: d.scaledSize(16, min: 14),
                    plated: false,
                    style: GoogleFonts.manrope(
                      color: colors.text1,
                      fontSize: d.scaledFont(13, min: 13),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: d.scaledSize(8)),
          if (owned)
            Icon(
              Icons.check_circle_rounded,
              color: colors.success,
              size: d.scaledSize(28, min: 24),
            )
          else
            PurchaseButton(
              label: t.buy,
              width: actionWidth,
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
