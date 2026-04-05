import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

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

// Current device is always first. Remote devices are derived from Supabase presence
// in future iterations; hard-coded for now since we don't have multi-device registration.
const kMockDevices = [
  DeviceInfo(
    name: 'This Device',
    icon: Icons.phone_iphone,
    isCurrentDevice: true,
    isOffline: false,
    lastActive: 'now',
  ),
];

final syncStateProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);

class SyncStateNotifier extends Notifier<SyncState> {
  RealtimeChannel? _channel;
  Timer? _notificationTimer;

  @override
  SyncState build() {
    ref.onDispose(() {
      _channel?.unsubscribe();
      _notificationTimer?.cancel();
    });
    _subscribe();
    return const SyncState(phase: SyncPhase.synced);
  }

  void _subscribe() {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    _channel = SupabaseService.client
        .channel('sync_status_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'campaigns',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _onRemoteChange,
        );

    _channel!.subscribe((RealtimeSubscribeStatus status, Object? error) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          if (state.phase == SyncPhase.offline) {
            state = const SyncState(phase: SyncPhase.syncing, catchUpProgress: 0.5);
            Future.delayed(const Duration(seconds: 2), () {
              state = const SyncState(phase: SyncPhase.synced);
            });
          }
        case RealtimeSubscribeStatus.channelError:
        case RealtimeSubscribeStatus.timedOut:
          state = const SyncState(phase: SyncPhase.offline, pendingChanges: 0);
        case RealtimeSubscribeStatus.closed:
          state = const SyncState(phase: SyncPhase.offline, pendingChanges: 0);
      }
    });
  }

  void _onRemoteChange(PostgresChangePayload payload) {
    final name = payload.newRecord['name'] as String?;
    state = SyncState(
      phase: SyncPhase.synced,
      incomingNotification: 'Remote update: ${name ?? 'campaign'} synced',
    );
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 4), () {
      state = const SyncState(phase: SyncPhase.synced);
    });
  }

  /// Called by upstream code (e.g. cloud sync screen) to signal sync started.
  void markSyncing() {
    state = const SyncState(phase: SyncPhase.syncing, catchUpProgress: 0.0);
  }

  /// Called when a local write has been successfully pushed to Supabase.
  void markSynced() {
    state = const SyncState(phase: SyncPhase.synced);
  }
}
