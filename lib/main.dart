import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_app/route/router.dart';


void main() {
  runApp( ProviderScope(
      child: App(),)
    );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '薬アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: Routes.router,
    );
  }
}

