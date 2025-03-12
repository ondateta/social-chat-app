import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:template/router.dart';
import 'package:template/src/design_system/app_theme.dart';
import 'package:template/src/views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      debugShowFloatingThemeButton: true,
      initial: AdaptiveThemeMode.system,
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      builder: (lightTheme, darkTheme) {
        return MaterialApp.router(
          title: 'My App',
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: router,
          builder: (context, child) => GateWay(
            child: child ?? SplashView(),
          ),
        );
      },
    );
  }
}

class GateWay extends StatefulWidget {
  const GateWay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<GateWay> createState() => _GateWayState();
}

class _GateWayState extends State<GateWay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}