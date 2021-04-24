import 'package:flutter/material.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: NavigationToolbar(
          leading: getBackButton(context),
          centerMiddle: true,
          middle: Text(title.toUpperCase(), style: Theme.of(context).appBarTheme.textTheme!.headline6, overflow: TextOverflow.ellipsis, maxLines: 1,)
        )
      ),
    );
  }

  Widget? getBackButton(BuildContext context) {
      final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
      final bool canPop = parentRoute?.canPop ?? false;
      final bool useCloseButton = parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
      if ( canPop ) {
        if ( useCloseButton ) {
          return CloseButton();
        } else {
          return BackButton();
        }
      }
      return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(92);
}