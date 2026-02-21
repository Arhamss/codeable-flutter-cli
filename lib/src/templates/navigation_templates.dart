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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/constants/app_colors.dart';
import 'package:{{project_name}}/constants/app_text_style.dart';
import 'package:{{project_name}}/constants/asset_paths.dart';
import 'package:{{project_name}}/core/models/navigation_item.dart';

// TODO: Uncomment and customise this navigation widget when you are
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
//       backgroundColor: AppColors.white,
//       body: shell,
//       bottomNavigationBar: Container(
//         height: 88,
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.black.withValues(alpha: 0.08),
//               blurRadius: 60,
//               offset: const Offset(0, -20),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.only(left: 32, right: 32, bottom: 12),
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
//   List<NavItem> get _navBarItems => [
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Home',
//     ),
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Search',
//     ),
//     const NavItem(
//       icon: AssetPaths.placeholderIcon, // TODO: Replace with your unselected icon
//       selectedIcon: AssetPaths.placeholderIcon, // TODO: Replace with your selected icon
//       label: 'Profile',
//     ),
//   ];
//
//   Widget _buildNavItem(BuildContext context, int index) {
//     final item = _navBarItems[index];
//     final isSelected = index == shell.currentIndex;
//     final color =
//         isSelected ? AppColors.blackPrimary : AppColors.textSecondary;
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
//             Text(item.label, style: context.l2.copyWith(color: color)),
//           ],
//         ),
//       ),
//     );
//   }
// }
''';
