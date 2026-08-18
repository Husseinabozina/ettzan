import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/responsive/responsive.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_asset_icon.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_logo.dart';

class EtzanPage extends StatelessWidget {
  const EtzanPage({
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBack = true,
    this.extendBody = false,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBack;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      extendBody: extendBody,
      appBar: title == null
          ? null
          : AppBar(
              leading: showBack && canPop ? const BackButton() : null,
              automaticallyImplyLeading: showBack && canPop,
              title: Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: title == null,
        child: ResponsiveCenter(
          child: Padding(
            padding: Responsive.pagePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}

class EtzanPrimaryButton extends StatelessWidget {
  const EtzanPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAsset,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null || iconAsset != null;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) ...[
          if (iconAsset != null)
            EtzanAssetIcon(iconAsset!, size: 21, color: Colors.white)
          else
            Icon(icon, size: 21),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: onPressed == null ? null : AppShadows.soft,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: AppColors.divider,
          shadowColor: Colors.transparent,
        ),
        child: content,
      ),
    );
  }
}

class EtzanSectionTitle extends StatelessWidget {
  const EtzanSectionTitle({
    required this.title,
    this.action,
    this.onAction,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class EtzanCard extends StatelessWidget {
  const EtzanCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.gradient,
    this.onTap,
    this.borderColor,
    this.shadows = AppShadows.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Color? borderColor;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).cardTheme.color ?? AppColors.card;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: borderColor ?? AppColors.divider),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class EtzanTag extends StatelessWidget {
  const EtzanTag(
      {required this.label, this.selected = false, this.onTap, super.key});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      showCheckmark: false,
      selectedColor: AppColors.secondary.withValues(alpha: .55),
      backgroundColor: AppColors.surface,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.primaryDeep : AppColors.inkMuted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}

class EtzanIconTile extends StatelessWidget {
  const EtzanIconTile({
    this.icon,
    this.iconAsset,
    required this.label,
    this.onTap,
    this.color = AppColors.primary,
    this.gradient = AppColors.softTealGradient,
    super.key,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return EtzanCard(
      onTap: onTap,
      gradient: gradient,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            alignment: Alignment.center,
            child: iconAsset != null
                ? EtzanAssetIcon(iconAsset!, color: color, size: 29)
                : Icon(icon, color: color, size: 29),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryDeep,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class EtzanProgressRing extends StatelessWidget {
  const EtzanProgressRing({required this.value, this.size = 92, super.key});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 9,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$percentage%',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class EtzanAvatar extends StatelessWidget {
  const EtzanAvatar(
      {required this.name, this.size = 52, this.online = false, super.key});

  final String name;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final letters = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join();
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.calmGradient,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: Text(
            letters,
            style: TextStyle(
                fontSize: size * .29,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark),
          ),
        ),
        if (online)
          PositionedDirectional(
            end: 1,
            bottom: 1,
            child: Container(
              width: size * .25,
              height: size * .25,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}

class EtzanMetric extends StatelessWidget {
  const EtzanMetric(
      {required this.value,
      required this.label,
      this.icon,
      this.iconAsset,
      super.key});

  final String value;
  final String label;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconAsset != null)
          EtzanAssetIcon(iconAsset!, color: AppColors.primary, size: 22)
        else if (icon != null)
          Icon(icon, color: AppColors.primary),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: AppColors.primaryDeep),
        ),
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
      ],
    );
  }
}

class EtzanHeroIllustration extends StatelessWidget {
  const EtzanHeroIllustration(
      {required this.asset, this.height = 260, super.key});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: SvgPicture.asset(asset, fit: BoxFit.contain),
    );
  }
}

class EtzanSegmentedControl<T> extends StatelessWidget {
  const EtzanSegmentedControl({
    required this.items,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Map<T, String> items;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F7),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: items.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Expanded(
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: isSelected ? AppShadows.card : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                onTap: () => onChanged(entry.key),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? AppColors.primaryDeep
                              : AppColors.inkMuted,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EtzanLoadingCard extends StatelessWidget {
  const EtzanLoadingCard({this.height = 124, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isCompact = height < 98;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment:
            isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 120, height: 16, decoration: _skeletonDecoration()),
          SizedBox(height: isCompact ? 8 : 14),
          Container(
              width: double.infinity,
              height: 12,
              decoration: _skeletonDecoration()),
          if (!isCompact) ...[
            const SizedBox(height: 10),
            Container(
                width: 190, height: 12, decoration: _skeletonDecoration()),
          ],
        ],
      ),
    );
  }

  BoxDecoration _skeletonDecoration() => BoxDecoration(
        color: AppColors.divider.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      );
}

class EtzanEmptyState extends StatelessWidget {
  const EtzanEmptyState(
      {required this.title, required this.body, this.action, super.key});

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EtzanLogo(compact: true),
        const SizedBox(height: AppSpacing.md),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(body,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
      ],
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid(
      {required this.children,
      this.phone = 1,
      this.tablet = 2,
      this.desktop = 3,
      this.spacing = 16,
      super.key});

  final List<Widget> children;
  final int phone;
  final int tablet;
  final int desktop;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final count = Responsive.gridCount(context,
        phone: phone, tablet: tablet, desktop: desktop);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing * (count - 1)) / count;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}
