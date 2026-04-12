import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 500,
  });

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

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double scaledSize(BuildContext context, double base, {double tabletMultiplier = 1.25}) {
    return isTablet(context) ? base * tabletMultiplier : base;
  }
}
