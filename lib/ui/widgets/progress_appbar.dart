import 'package:flutter/material.dart';


class ProgressAppBar extends StatelessWidget implements PreferredSizeWidget {

  final double progress;
  final bool hideProgressBar;

  const ProgressAppBar({Key? key, this.progress = 0, this.hideProgressBar = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: NavigationToolbar(
          leading: Navigator.of(context).canPop() ? BackButton() : null,
          centerMiddle: true,
          middle: this.hideProgressBar ? null : ClipRRect(
            borderRadius: BorderRadius.circular(30), 
            child: LinearProgressIndicator(
              value: progress, backgroundColor: Colors.grey, 
              valueColor: AlwaysStoppedAnimation(Colors.black), 
            )
          )
        )
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}