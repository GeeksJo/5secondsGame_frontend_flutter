import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveLayout({super.key, required this.child, this.maxWidth = 500});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Height of the view minus system padding (rough usable vertical space).
  static double usableHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.size.height - mq.padding.vertical;
  }

  static bool isCompactHeight(BuildContext context, {double threshold = 480}) {
    return usableHeight(context) < threshold;
  }

  /// Two-column game layout: tablet landscape, wide phone landscape, or
  /// very wide + short windows.
  static bool useWideGameLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tablet = isTablet(context);
    final landscape = isLandscape(context);
    if (tablet && landscape) return true;
    if (!tablet && landscape && size.width >= 600) return true;
    if (isCompactHeight(context) && size.width >= 700) return true;
    return false;
  }

  /// Content max width: phone vs tablet portrait vs tablet landscape.
  static double maxWidthFor(
    BuildContext context, {
    required double phone,
    required double tabletPortrait,
    required double tabletLandscape,
  }) {
    if (!isTablet(context)) return phone;
    if (isLandscape(context)) return tabletLandscape;
    return tabletPortrait;
  }

  /// Extra horizontal inset for tablet content columns (callers add to padding).
  static double tabletContentHorizontalInset(BuildContext context) {
    if (!isTablet(context)) return 0;
    return isLandscape(context) ? 24 : 28;
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100 && isLandscape(context)) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  /// Category grid: slightly shorter cells in landscape so titles fit.
  static double categoryGridChildAspectRatio(BuildContext context) {
    if (isLandscape(context)) {
      return isTablet(context) ? 1.10 : 1.25;
    }
    return isTablet(context) ? 1.02 : 1.1;
  }

  static double scaledSize(
    BuildContext context,
    double base, {
    double tabletMultiplier = 1.25,
  }) {
    return isTablet(context) ? base * tabletMultiplier : base;
  }

  /// Primary DONE control: larger on tablet portrait, capped in wide+compact.
  static double redButtonDiameter(BuildContext context) {
    final tablet = isTablet(context);
    final wide = useWideGameLayout(context);
    final compact = isCompactHeight(context);
    if (wide && compact) {
      return tablet ? 132 : 108;
    }
    if (tablet) return 140;
    return 118;
  }
}
