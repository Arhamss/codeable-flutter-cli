// ============================================================
// Navigation templates — NavItem model + shell navigation widget
// Generated code is fully commented out with placeholder values
// so users can uncomment and customise when ready.
// ============================================================

const navItemModelTemplate = '''
class NavItem {
  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String icon;
  final String selectedIcon;
  final String label;
}
''';

const navigationWidgetTemplate = '''
// TODO(codeable): Uncomment these imports together with the widget below
// when you are ready to add bottom-tab navigation to your app.
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:{{project_name}}/constants/app_colors.dart';
// import 'package:{{project_name}}/constants/app_text_style.dart';
// import 'package:{{project_name}}/constants/asset_paths.dart';
// import 'package:{{project_name}}/core/models/navigation_item.dart';

// TODO(codeable): Uncomment and customise this navigation widget when you are
// ready to add bottom-tab navigation to your app.
//
// class AppNavigation extends StatelessWidget {
//   const AppNavigation({required this.shell, super.key});
//
//   final StatefulNavigationShell shell;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: AppColors.surface,
//       body: shell,
//       // TODO: extract to dimension constants (height, blur radius,
//       // offset, alpha, and paddings below are magic numbers).
//       bottomNavigationBar: Container(
//         height: 88,
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.overlayScrim.withValues(alpha: 0.08),
//               blurRadius: 60,
//               offset: const Offset(0, -20),
//             ),
//           ],
//         ),
//         padding: const EdgeInsetsDirectional.only(start: 32, end: 32, bottom: 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(
//             _navBarItems.length,
//             (index) => Expanded(child: _buildNavItem(context, index)),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // TODO: Localize all NavItem labels. Replace the hardcoded strings
//   // below with context.l10n.<key> (the 'home' key already exists; add
//   // 'search' and 'profile' keys to your .arb files). Note: context.l10n
//   // values are not const, so drop `const` from these NavItem entries when
//   // you switch to localized labels.
//   List<NavItem> get _navBarItems => [
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Home', // TODO: localize -> context.l10n.home
//     ),
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Search', // TODO: localize (add 'search' key to .arb)
//     ),
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Profile', // TODO: localize (add 'profile' key to .arb)
//     ),
//   ];
//
//   Widget _buildNavItem(BuildContext context, int index) {
//     final item = _navBarItems[index];
//     final isSelected = index == shell.currentIndex;
//     final color =
//         isSelected ? AppColors.primary : AppColors.textSecondary;
//
//     return GestureDetector(
//       onTap: () => shell.goBranch(index, initialLocation: true),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 12, bottom: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(
//               isSelected ? item.selectedIcon : item.icon,
//             ),
//             const SizedBox(height: 4),
//             Text(item.label, style: context.captionMedium.copyWith(color: color)),
//           ],
//         ),
//       ),
//     );
//   }
// }
''';
