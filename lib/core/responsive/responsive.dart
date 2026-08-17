import 'package:flutter/material.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';

abstract final class Responsive {
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.phone;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.phone && width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.tablet) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    }
    if (width >= AppBreakpoints.phone) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static double maxContentWidth(BuildContext context) =>
      AppBreakpoints.contentMax;

  static int gridCount(BuildContext context,
      {int phone = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return phone;
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        child: child,
      ),
    );
  }
}
