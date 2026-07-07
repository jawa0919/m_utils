import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';

import 'app_import.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(AppStatic.designWidth, AppStatic.designHeight),
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: !MUtils.isProduct,
        title: MUtils.packageName,

        routerConfig: AppRoutes.routerConfig..observers?.add(ExDialog.observer),
        builder: (context, child) {
          child = ExDialog.builder(context, child);
          return child;
        },

        theme: ThemeStore.to.lightTheme.value,
        darkTheme: ThemeStore.to.darkTheme.value,
        themeMode: ThemeStore.to.themeMode.watch(context),

        localizationsDelegates: LanguageStore.to.localizationsDelegates,
        supportedLocales: LanguageStore.to.supportedLocales,
        locale: LanguageStore.to.locale.watch(context),
      ),
    );
  }
}
