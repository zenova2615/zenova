import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_colors.dart';
import '../core/services/update_service.dart';
import 'routes.dart';

class ZenovaApp extends ConsumerStatefulWidget {
  const ZenovaApp({super.key});

  @override
  ConsumerState<ZenovaApp> createState() => _ZenovaAppState();
}

class _ZenovaAppState extends ConsumerState<ZenovaApp> {
  @override
  void initState() {
    super.initState();
    // অ্যাপ চালু হওয়ার একটু পরে আপডেট চেক করবে
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp.router(
      title: 'ZENOVA Media',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
