import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/campaign.dart';
import 'models/campaign_adapter.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CampaignAdapter());
  await Hive.openBox<Campaign>('campaigns');
  await NotificationService.initialize();
  runApp(const ProviderScope(child: MTBoxApp()));
}

class MTBoxApp extends StatefulWidget {
  const MTBoxApp({super.key});

  @override
  State<MTBoxApp> createState() => _MTBoxAppState();
}

class _MTBoxAppState extends State<MTBoxApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter('/');
    NotificationService.onNotificationTap = (campaignId) {
      _router.push('/campaigns/$campaignId');
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MTBox Campaign Tracker',
      theme: kBrutalistTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
