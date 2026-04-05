import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/providers/sync_provider.dart';

void main() {
  group('SyncState', () {
    test('initial state has correct defaults', () {
      const state = SyncState(phase: SyncPhase.synced);
      expect(state.phase, SyncPhase.synced);
      expect(state.pendingChanges, 0);
      expect(state.catchUpProgress, 0.0);
      expect(state.incomingNotification, isNull);
    });

    test('can create state with custom values', () {
      const state = SyncState(
        phase: SyncPhase.syncing,
        pendingChanges: 5,
        catchUpProgress: 0.75,
        incomingNotification: 'Test message',
      );
      expect(state.phase, SyncPhase.syncing);
      expect(state.pendingChanges, 5);
      expect(state.catchUpProgress, 0.75);
      expect(state.incomingNotification, 'Test message');
    });

    test('synced phase has zero pending changes', () {
      const state = SyncState(phase: SyncPhase.synced);
      expect(state.phase, SyncPhase.synced);
      expect(state.pendingChanges, 0);
    });

    test('offline phase has pending changes', () {
      const state = SyncState(phase: SyncPhase.offline, pendingChanges: 3);
      expect(state.phase, SyncPhase.offline);
      expect(state.pendingChanges, 3);
    });

    test('syncing phase has progress between 0 and 1', () {
      const state = SyncState(
        phase: SyncPhase.syncing,
        catchUpProgress: 0.5,
      );
      expect(state.catchUpProgress, greaterThanOrEqualTo(0.0));
      expect(state.catchUpProgress, lessThanOrEqualTo(1.0));
    });
  });

  group('DeviceInfo', () {
    test('can create device for current device', () {
      const device = DeviceInfo(
        name: 'iPhone 14 Pro',
        icon: Icons.phone_iphone,
        isCurrentDevice: true,
        isOffline: false,
        lastActive: 'now',
      );
      expect(device.name, 'iPhone 14 Pro');
      expect(device.isCurrentDevice, true);
      expect(device.isOffline, false);
      expect(device.lastActive, 'now');
    });

    test('can create offline device', () {
      const device = DeviceInfo(
        name: 'iPad Air',
        icon: Icons.tablet_mac,
        isCurrentDevice: false,
        isOffline: true,
        lastActive: '3 hrs ago',
      );
      expect(device.isOffline, true);
      expect(device.isCurrentDevice, false);
    });

    test('can create synced remote device', () {
      const device = DeviceInfo(
        name: 'MacBook Pro',
        icon: Icons.laptop_mac,
        isCurrentDevice: false,
        isOffline: false,
        lastActive: '2 min ago',
      );
      expect(device.isCurrentDevice, false);
      expect(device.isOffline, false);
      expect(device.lastActive, '2 min ago');
    });
  });

  group('Mock devices constant', () {
    test('kMockDevices has 3 devices', () {
      expect(kMockDevices.length, 3);
    });

    test('first device is current device', () {
      expect(kMockDevices.first.isCurrentDevice, true);
    });

    test('contains devices with various states', () {
      final hasOfflineDevice =
          kMockDevices.any((d) => d.isOffline);
      final hasSyncedRemote =
          kMockDevices.any((d) => !d.isCurrentDevice && !d.isOffline);

      expect(hasOfflineDevice, true);
      expect(hasSyncedRemote, true);
    });

    test('device names are descriptive', () {
      expect(kMockDevices.map((d) => d.name).toSet().length, 3);
      expect(
        kMockDevices.map((d) => d.name).toList(),
        containsAll(['iPhone 14 Pro', 'MacBook Pro', 'iPad Air']),
      );
    });
  });

  group('SyncPhase enum', () {
    test('has expected values', () {
      expect(SyncPhase.synced, isNotNull);
      expect(SyncPhase.syncing, isNotNull);
      expect(SyncPhase.offline, isNotNull);
    });

    test('values are distinct', () {
      final values = {SyncPhase.synced, SyncPhase.syncing, SyncPhase.offline};
      expect(values.length, 3);
    });
  });
}
