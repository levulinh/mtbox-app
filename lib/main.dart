import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/campaign.dart';
import 'models/campaign_adapter.dart';
import 'models/user_account.dart';
import 'models/user_account_adapter.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CampaignAdapter());
  Hive.registerAdapter(UserAccountAdapter());
  await Hive.openBox<Campaign>('campaigns');
  await Hive.openBox<UserAccount>('users');
  await Hive.openBox('settings');
  await NotificationService.initialize();

  final settings = Hive.box('settings');
  if (!settings.containsKey('memberSince')) {
    settings.put('memberSince', DateTime.now().millisecondsSinceEpoch);
  }
  final currentUser = settings.get('currentUser') as String?;
  final onboardingDone = settings.get('onboardingDone', defaultValue: false) as bool;

  final String initialLocation;
  if (currentUser == null) {
    initialLocation = '/sign-in';
  } else if (!onboardingDone) {
    initialLocation = '/onboarding';
  } else {
    initialLocation = '/';
  }

  runApp(ProviderScope(child: MTBoxApp(initialLocation: initialLocation)));
}

class MTBoxApp extends StatefulWidget {
  final String initialLocation;

  const MTBoxApp({super.key, this.initialLocation = '/'});

  @override
  State<MTBoxApp> createState() => _MTBoxAppState();
}

class _MTBoxAppState extends State<MTBoxApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.initialLocation);
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
