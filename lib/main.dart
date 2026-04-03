import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: MTBoxApp()));
}

class MTBoxApp extends StatelessWidget {
  const MTBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MTBox Campaign Tracker',
      theme: kBrutalistTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
