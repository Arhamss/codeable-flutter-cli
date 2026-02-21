import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:test_app/exports.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.size = 24,
    this.color = AppColors.primary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Platform.isIOS
            ? CupertinoActivityIndicator(color: color)
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 1.5,
              ),
      ),
    );
  }
}
