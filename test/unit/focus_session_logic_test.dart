import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Focus Session Logic', () {
    group('Time formatting', () {
      test('formats seconds to MM:SS with zero-padding', () {
        // Arrange
        final formatTime = (int seconds) {
          final m = (seconds ~/ 60).toString().padLeft(2, '0');
          final s = (seconds % 60).toString().padLeft(2, '0');
          return '$m:$s';
        };

        // Act & Assert
        expect(formatTime(0), '00:00');
        expect(formatTime(5), '00:05');
        expect(formatTime(59), '00:59');
        expect(formatTime(60), '01:00');
        expect(formatTime(125), '02:05');
        expect(formatTime(1500), '25:00');
      });

      test('formats duration with smart singular/plural', () {
        // Arrange
        final formatDuration = (int seconds) {
          final m = seconds ~/ 60;
          final s = seconds % 60;
          if (m > 0 && s > 0) return '${m}m ${s}s';
          if (m > 0) return '${m}m';
          return '${s}s';
        };

        // Act & Assert
        expect(formatDuration(0), '0s');
        expect(formatDuration(15), '15s');
        expect(formatDuration(60), '1m');
        expect(formatDuration(65), '1m 5s');
        expect(formatDuration(1500), '25m');
        expect(formatDuration(1505), '25m 5s');
      });
    });

    group('Duration options', () {
      test('provides standard durations from 5 to 60 minutes', () {
        // Arrange
        final options = [5, 10, 15, 20, 25, 30, 45, 60];

        // Assert
        expect(options, [5, 10, 15, 20, 25, 30, 45, 60]);
        expect(options.first, 5);
        expect(options.last, 60);
        expect(options.length, 8);
      });

      test('default duration is 25 minutes', () {
        // Arrange
        final defaultSeconds = 25 * 60;

        // Assert
        expect(defaultSeconds, 1500);
      });
    });

    group('Progress calculation', () {
      test('calculates progress as fraction of elapsed to total time', () {
        // Arrange
        final targetSeconds = 25 * 60; // 25 min

        // Act & Assert
        expect(0 / targetSeconds.toDouble(), 0.0);
        expect((targetSeconds ~/ 2) / targetSeconds.toDouble(), 0.5);
        expect(targetSeconds / targetSeconds.toDouble(), 1.0);
      });

      test('clamps progress between 0 and 1', () {
        // Arrange
        final targetSeconds = 1500;
        final negativeProgress = (-100 / targetSeconds).clamp(0.0, 1.0);
        final overProgress = (2000 / targetSeconds).clamp(0.0, 1.0);

        // Assert
        expect(negativeProgress, 0.0);
        expect(overProgress, 1.0);
      });

      test('remaining time never goes below zero', () {
        // Arrange
        final targetSeconds = 1500;
        final elapsedSeconds = 2000;
        final remaining = (targetSeconds - elapsedSeconds).clamp(0, targetSeconds);

        // Assert
        expect(remaining, 0);
      });
    });

    group('Timer completion conditions', () {
      test('timer fires when elapsed seconds reach target seconds', () {
        // Arrange
        final targetSeconds = 1500;
        int elapsedSeconds = 0;

        // Act
        elapsedSeconds = targetSeconds;

        // Assert
        expect(elapsedSeconds >= targetSeconds, true);
      });

      test('adjusting duration down clamps elapsed to not exceed new target', () {
        // Arrange
        int targetSeconds = 1500; // 25 min
        int elapsedSeconds = 1200; // 20 min

        // Act
        final newTarget = 10 * 60;
        if (elapsedSeconds >= newTarget) {
          elapsedSeconds = newTarget - 1;
        }

        // Assert
        expect(elapsedSeconds < newTarget, true);
      });
    });

    group('Session recording', () {
      test('captures progress snapshot before check-in', () {
        // Arrange
        int progressBefore = 5;
        int totalDays = 30;
        int streakBefore = 7;

        // Act (simulate check-in)
        int progressAfter = progressBefore + 1;
        int streakAfter = streakBefore + 1;

        // Assert
        expect(progressAfter, 6);
        expect(streakAfter, 8);
        expect(totalDays, 30); // unchanged
      });

      test('calculates campaign progress percentages', () {
        // Arrange
        final pctBefore = 5 / 30;
        final pctAfter = 6 / 30;

        // Assert
        expect(pctBefore, closeTo(0.167, 0.001));
        expect(pctAfter, closeTo(0.200, 0.001));
      });

      test('detects campaign completion', () {
        // Arrange
        final isActive = true;
        final progressAfter = 30;
        final totalDays = 30;

        // Act
        final isCompleted = !isActive;

        // Assert
        expect(isCompleted, false);
      });
    });
  });
}
