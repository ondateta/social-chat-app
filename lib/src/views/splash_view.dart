import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:template/src/design_system/app_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppLogo(),
            Gap(16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
