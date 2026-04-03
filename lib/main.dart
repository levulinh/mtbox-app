import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/campaign.dart';
import 'models/campaign_adapter.dart';
import 'router.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CampaignAdapter());
  await Hive.openBox<Campaign>('campaigns');
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
