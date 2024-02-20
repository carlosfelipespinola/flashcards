import 'package:flutter/material.dart';

class ProgressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;

  const ProgressAppBar({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            )));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
