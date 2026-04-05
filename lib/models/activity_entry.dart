class ActivityEntry {
  final String campaignName;
  final DateTime date;
  final bool completed;
  final int dayNumber;
  final int totalDays;
  final bool isPending;
  final String? deviceName; // device that performed this action (null = this device)

  const ActivityEntry({
    required this.campaignName,
    required this.date,
    required this.completed,
    this.dayNumber = 0,
    this.totalDays = 0,
    this.isPending = false,
    this.deviceName,
  });
}
