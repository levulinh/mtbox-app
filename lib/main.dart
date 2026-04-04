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
  await Hive.openBox('settings');
  final onboardingDone =
      Hive.box('settings').get('onboardingDone', defaultValue: false) as bool;
  final initialLocation = onboardingDone ? '/' : '/onboarding';
  runApp(ProviderScope(child: MTBoxApp(initialLocation: initialLocation)));
}

class MTBoxApp extends StatelessWidget {
  final String initialLocation;

  const MTBoxApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MTBox Campaign Tracker',
      theme: kBrutalistTheme,
      routerConfig: createRouter(initialLocation),
      debugShowCheckedModeBanner: false,
    );
  }
}
