# Design System

## Foundation

Primary tokens are stored in:

- `AppColors`
- `AppSpacing`
- `AppRadii`
- `AppDurations`
- `AppBreakpoints`
- `AppShadows`
- `AppTheme`

## Palette

- Primary teal: `#0FA398`
- Dark teal: `#08766F`
- Mint: `#A7E3D9`
- Lavender: `#CDB4F7`
- Soft lavender: `#EDEDF3`
- Background: `#F7F9FB`
- Ink: `#10233F`

## Responsive behavior

- Phone: width below 600 px.
- Tablet: 600–1023 px.
- Desktop: 1024 px and above.
- Maximum content width: 1180 px.

Phone layouts use bottom navigation. Tablet and desktop layouts switch to `NavigationRail`; desktop expands it to show labels. Adaptive grids alter their column count automatically.

## RTL/LTR rules

- No screen hardcodes `TextDirection`.
- The app locale drives direction through Flutter localization delegates.
- Direction-aware APIs are used: `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, and `PositionedDirectional`.
- Arabic and English can be switched at runtime from Settings.

## Reusable components

- `EtzanPage`
- `EtzanShell`
- `EtzanPrimaryButton`
- `EtzanCard`
- `EtzanTag`
- `EtzanIconTile`
- `EtzanProgressRing`
- `EtzanAvatar`
- `EtzanMetric`
- `EtzanHeroIllustration`
- `EtzanEmptyState`
- `AdaptiveGrid`
