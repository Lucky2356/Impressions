import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Значок приложения — тот же файл, что на рабочем столе и в меню «Пуск».
///
/// Раньше внутри рисовалась закладка из шрифта значков, и приложение в списке
/// программ выглядело не так, как внутри себя.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 34, this.borderRadius});

  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppDimens.brSm,
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
