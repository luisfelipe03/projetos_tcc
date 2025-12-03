import 'package:flutter/material.dart';
import '../core/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? bottom;

  const CustomAppBar({super.key, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom != null ? AppSizes.appBarHeight : 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppStrings.appTitle),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: const SizedBox(),
      bottom:
          bottom != null
              ? PreferredSize(
                preferredSize: Size.fromHeight(AppSizes.appBarHeight),
                child: bottom!,
              )
              : null,
    );
  }
}
