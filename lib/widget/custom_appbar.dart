import 'package:flutter/material.dart';
import 'package:gbsw_capstone_appsters/const/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Color backgroundColor;
  final double elevation;
  final double scrolledUnderElevation;
  final List<Widget>? actions;
  final Widget? leading;
  final String? logoPath;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.centerTitle = false,
    this.bottom,
    this.backgroundColor = AppColors.primaryColor,
    this.elevation = 1.0,
    this.scrolledUnderElevation = 1.0,
    this.actions,
    this.leading,
    this.logoPath,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        bottom != null ? 100 + bottom!.preferredSize.height : 50.0,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (logoPath != null && logoPath!.isNotEmpty)
            Image.asset(
              logoPath!,
              color: AppColors.primaryColor,
              width: 30,
            ),
          if (logoPath != null && logoPath!.isNotEmpty)
            const SizedBox(width: 5),
          Text(
            title,
            style: titleStyle,
          ),
        ],
      ),
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      bottom: bottom,
      actions: actions,
    );
  }
}
