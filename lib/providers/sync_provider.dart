import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncPhase { synced, syncing, offline }

class DeviceInfo {
  final String name;
  final IconData icon;
  final bool isCurrentDevice;
  final bool isOffline;
  final String lastActive;

  const DeviceInfo({
    required this.name,
    required this.icon,
    required this.isCurrentDevice,
    required this.isOffline,
    required this.lastActive,
  });
}

class SyncState {
  final SyncPhase phase;
  final int pendingChanges;
  final double catchUpProgress;
  final String? incomingNotification;

  const SyncState({
    required this.phase,
    this.pendingChanges = 0,
    this.catchUpProgress = 0.0,
    this.incomingNotification,
  });
}

// Hard-coded mock device list — current device is always first.
const kMockDevices = [
  DeviceInfo(
    name: 'iPhone 14 Pro',
    icon: Icons.phone_iphone,
    isCurrentDevice: true,
    isOffline: false,
    lastActive: 'now',
  ),
  DeviceInfo(
    name: 'MacBook Pro',
    icon: Icons.laptop_mac,
    isCurrentDevice: false,
    isOffline: false,
    lastActive: '2 min ago',
  ),
  DeviceInfo(
    name: 'iPad Air',
    icon: Icons.tablet_mac,
    isCurrentDevice: false,
    isOffline: true,
    lastActive: '3 hrs ago',
  ),
];

final syncStateProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);

class SyncStateNotifier extends Notifier<SyncState> {
  Timer? _t1;
  Timer? _t2;
  Timer? _progressTimer;

  @override
  SyncState build() {
    ref.onDispose(() {
      _t1?.cancel();
      _t2?.cancel();
      _progressTimer?.cancel();
    });
    _scheduleOffline();
    return const SyncState(phase: SyncPhase.synced);
  }

  void _scheduleOffline() {
    _t1 = Timer(const Duration(seconds: 15), _goOffline);
  }

  void _goOffline() {
    state = const SyncState(phase: SyncPhase.offline, pendingChanges: 3);
    _t2 = Timer(const Duration(seconds: 6), _goSyncing);
  }

  void _goSyncing() {
    state = const SyncState(
        phase: SyncPhase.syncing, pendingChanges: 3, catchUpProgress: 0.0);
    double progress = 0.0;
    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 150), (timer) {
      progress = (progress + 0.05).clamp(0.0, 1.0);
      state = SyncState(
          phase: SyncPhase.syncing,
          pendingChanges: 3,
          catchUpProgress: progress);
      if (progress >= 1.0) {
        timer.cancel();
        _goSynced();
      }
    });
  }

  void _goSynced() {
    state = const SyncState(
      phase: SyncPhase.synced,
      incomingNotification:
          'MacBook Pro checked in Morning Run · 2 new changes applied',
    );
    // Dismiss notification after 4s, then schedule next cycle
    _t1 = Timer(const Duration(seconds: 4), () {
      state = const SyncState(phase: SyncPhase.synced);
      _scheduleOffline();
    });
  }
}
