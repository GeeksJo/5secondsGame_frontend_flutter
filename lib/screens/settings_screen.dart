import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_kit/game_kit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalla/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../services/game_kit_products.dart';
import '../services/premium_service.dart';
import '../services/purchase_service.dart';
import '../services/rating_service.dart';
import '../services/sharing_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cross_promo_sheet.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/settings/donation_sheet.dart';
import '../widgets/settings/setting_item.dart';
import '../widgets/settings/setting_section.dart';
import '../widgets/settings/settings_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey _shareButtonKey = GlobalKey();

  StreamSubscription<String>? _completeSub;
  StreamSubscription<String>? _restoredSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<void>? _startedSub;
  bool _purchaseBusy = false;
  bool _restoreBusy = false;
  DateTime? _lastRestoreAt;
  bool _purchaseListenersAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_purchaseListenersAttached) return;
    _purchaseListenersAttached = true;
    final purchases = context.read<PurchaseService>();

    _completeSub = purchases.onPurchaseComplete.listen(
      (productId) => unawaited(_onPurchaseComplete(productId)),
    );

    _restoredSub = purchases.onPurchaseRestored.listen((_) {
      if (!mounted) return;
      setState(() {});
    });

    _errorSub = purchases.onPurchaseError.listen((code) {
      if (!mounted) return;
      setState(() => _purchaseBusy = false);
      final l10n = AppLocalizations.of(context)!;
      final lower = code.toLowerCase();
      if (lower.contains('cancel')) return;
      final msg = switch (code) {
        'store_unavailable' => l10n.storeUnavailable,
        'product_not_found' => l10n.errorTitle,
        'purchase_failed' => l10n.purchaseFailed,
        _ => l10n.purchaseFailed,
      };
      unawaited(SettingsDialogs.showError(context, msg));
    });

    _startedSub = purchases.onPurchaseStarted.listen((_) {
      if (!mounted) return;
      setState(() => _purchaseBusy = true);
    });
  }

  Future<void> _onPurchaseComplete(String productId) async {
    if (!mounted) return;
    setState(() => _purchaseBusy = false);

    if (productId == GameKitProducts.removeAds) {
      final recentRestore =
          _lastRestoreAt != null &&
          DateTime.now().difference(_lastRestoreAt!) <
              const Duration(seconds: 4);
      if (recentRestore) return;
      await SettingsDialogs.showSuccess(
        context,
        title: AppLocalizations.of(context)!.purchaseSuccessRemoveAdsTitle,
        message: AppLocalizations.of(context)!.purchaseSuccessRemoveAdsMessage,
      );
      return;
    }

    if (_isDonation(productId)) {
      final amount = _donationAmountUsd(productId);
      final premium = context.read<PremiumService>();
      await premium.addDonation(productId, amount);
      if (!mounted) return;
      final total = await premium.getTotalDonations();
      if (!mounted) return;
      final locale = Localizations.localeOf(context).toLanguageTag();
      final formatted = NumberFormat.currency(
        locale: locale,
        symbol: r'$',
      ).format(total);
      await SettingsDialogs.showSuccess(
        context,
        title: AppLocalizations.of(context)!.donationSuccessTitle,
        message: AppLocalizations.of(context)!.donationSuccessBody(formatted),
      );
    }
  }

  bool _isDonation(String productId) {
    return productId == GameKitProducts.donationSmall ||
        productId == GameKitProducts.donationMedium ||
        productId == GameKitProducts.donationLarge;
  }

  double _donationAmountUsd(String productId) {
    if (productId == GameKitProducts.donationSmall) return 0.99;
    if (productId == GameKitProducts.donationMedium) return 4.99;
    if (productId == GameKitProducts.donationLarge) return 9.99;
    return 0;
  }

  @override
  void dispose() {
    unawaited(_completeSub?.cancel());
    unawaited(_restoredSub?.cancel());
    unawaited(_errorSub?.cancel());
    unawaited(_startedSub?.cancel());
    super.dispose();
  }

  Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _removeAdsFlow(PurchaseService purchases) async {
    final price = purchases.getFormattedPrice(GameKitProducts.removeAds);
    final ok = await SettingsDialogs.showConfirmRemoveAds(
      context,
      price: price,
    );
    if (!ok || !mounted) return;
    await purchases.purchaseProduct(GameKitProducts.removeAds);
  }

  Future<void> _restoreFlow(PurchaseService purchases) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context)!;
    setState(() => _restoreBusy = true);
    messenger?.showSnackBar(SnackBar(content: Text(l10n.restoreInProgress)));
    final ok = await purchases.restorePurchases();
    if (ok) _lastRestoreAt = DateTime.now();
    if (!mounted) return;
    setState(() => _restoreBusy = false);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.purchasesRestored : l10n.purchaseFailed),
      ),
    );
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await SharingService.shareApp(
      context: context,
      sharePositionOrigin: origin,
      message: l10n.shareAppMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final purchases = context.read<PurchaseService>();
    final pending =
        _purchaseBusy ||
        _restoreBusy ||
        GameKit.iap.isPending ||
        purchases.isRestoring;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBg,
        child: ResponsiveLayout(
          maxWidth: 520,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              SettingSection(
                title: l10n.sectionAppInfo,
                titleIcon: Icons.info_outline_rounded,
                children: [
                  SettingItem(
                    icon: Icons.celebration_outlined,
                    iconBackground: AppColors.primary.withValues(alpha: 0.45),
                    title: l10n.appName,
                    subtitle: l10n.appInfoLine,
                    onTap: null,
                    enabled: false,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _buildTile(
                icon: localeProvider.soundEnabled
                    ? Icons.volume_up
                    : Icons.volume_off,
                title: l10n.sound,
                trailing: Switch(
                  value: localeProvider.soundEnabled,
                  onChanged: (_) => localeProvider.toggleSound(),
                  activeTrackColor: AppColors.textHint,
                  activeThumbColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              SettingSection(
                title: l10n.sectionPremium,
                titleIcon: Icons.workspace_premium_outlined,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: GameKit.iap.adsRemoved,
                    builder: (context, removed, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingItem(
                            icon: removed
                                ? Icons.verified_rounded
                                : Icons.visibility_off_outlined,
                            iconBackground: removed
                                ? AppColors.correct.withValues(alpha: 0.55)
                                : Colors.orange.withValues(alpha: 0.55),
                            title: l10n.removeAds,
                            subtitle: l10n.removeAdsSubtitle,
                            enabled: !pending,
                            trailing: removed
                                ? Chip(
                                    label: Text(
                                      l10n.activatedLabel,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.family,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: AppColors.correct
                                        .withValues(alpha: 0.25),
                                  )
                                : Chip(
                                    label: Text(
                                      purchases.getFormattedPrice(
                                        GameKitProducts.removeAds,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: AppFonts.family,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: AppColors.cardBorder
                                        .withValues(alpha: 0.6),
                                  ),
                            onTap: removed || pending
                                ? null
                                : () => _removeAdsFlow(purchases),
                          ),
                          SettingItem(
                            icon: Icons.restore_rounded,
                            iconBackground: AppColors.primaryDeep.withValues(
                              alpha: 0.5,
                            ),
                            title: l10n.restorePurchases,
                            subtitle: l10n.restorePurchasesSubtitle,
                            enabled: !pending,
                            onTap: pending
                                ? null
                                : () => _restoreFlow(purchases),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SettingSection(
                title: l10n.sectionSupport,
                titleIcon: Icons.favorite_outline,
                children: [
                  SettingItem(
                    icon: Icons.volunteer_activism_outlined,
                    iconBackground: const Color(
                      0xFF00897B,
                    ).withValues(alpha: 0.45),
                    title: l10n.donateTitle,
                    subtitle: l10n.donateSubtitle,
                    enabled: !pending,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onTap: pending
                        ? null
                        : () => showDonationTierSheet(
                            context: context,
                            purchases: purchases,
                            l10n: l10n,
                            purchasing: pending,
                            onPick: (id) => purchases.purchaseProduct(id),
                          ),
                  ),
                  SettingItem(
                    icon: Icons.star_rate_rounded,
                    iconBackground: AppColors.coin.withValues(alpha: 0.35),
                    title: l10n.rateApp,
                    enabled: true,
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => RatingService.openStoreDirectly(),
                  ),
                  SettingItem(
                    key: _shareButtonKey,
                    icon: Icons.ios_share_rounded,
                    iconBackground: AppColors.primary.withValues(alpha: 0.4),
                    title: l10n.shareApp,
                    enabled: true,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onTap: _share,
                  ),
                  SettingItem(
                    icon: Icons.apps_outlined,
                    iconBackground: AppColors.cardBorder,
                    title: l10n.moreGames,
                    enabled: true,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => showCrossPromoSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SettingSection(
                title: l10n.sectionContact,
                titleIcon: Icons.mail_outline,
                children: [
                  SettingItem(
                    icon: Icons.email_outlined,
                    iconBackground: AppColors.primary.withValues(alpha: 0.35),
                    title: l10n.contactEmailTitle,
                    subtitle: l10n.contactEmailSubtitle,
                    enabled: true,
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _launchUri(GameKitProducts.feedbackMailto),
                  ),
                  SettingItem(
                    icon: Icons.language,
                    iconBackground: AppColors.primaryDark.withValues(
                      alpha: 0.45,
                    ),
                    title: l10n.websiteTitle,
                    subtitle: l10n.websiteSubtitle,
                    enabled: true,
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _launchUri(GameKitProducts.websiteUrl),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
