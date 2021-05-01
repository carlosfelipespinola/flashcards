import 'package:flutter/material.dart';


class ProgressAppBar extends StatelessWidget implements PreferredSizeWidget {

  final double progress;
  final bool hideProgressBar;

  const ProgressAppBar({Key? key, this.progress = 0, this.hideProgressBar = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}