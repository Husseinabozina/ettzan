import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EtzanAssetIcon extends StatelessWidget {
  const EtzanAssetIcon(
    this.asset, {
    this.size = 24,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final String asset;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

class EtzanIconBadge extends StatelessWidget {
  const EtzanIconBadge({
    required this.asset,
    required this.color,
    this.size = 52,
    this.iconSize = 27,
    super.key,
  });

  final String asset;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(size * .32),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      alignment: Alignment.center,
      child: EtzanAssetIcon(asset, size: iconSize, color: color),
    );
  }
}
