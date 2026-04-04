import 'package:hive_flutter/hive_flutter.dart';
import 'campaign.dart';

class CampaignAdapter extends TypeAdapter<Campaign> {
  @override
  final int typeId = 0;

  @override
  Campaign read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final goal = reader.readString();
    final totalDays = reader.readInt();
    final currentDay = reader.readInt();
    final isActive = reader.readBool();
    final dayHistory = reader.readList().cast<bool>();
    // Backward-compatible optional field added in MTB-11
    String? lastCheckInDate;
    if (reader.availableBytes > 0) {
      final hasDate = reader.readBool();
      if (hasDate) lastCheckInDate = reader.readString();
    }
    // Backward-compatible optional fields added in MTB-22
    bool reminderEnabled = false;
    String? reminderTime;
    if (reader.availableBytes > 0) {
      reminderEnabled = reader.readBool();
      final hasReminderTime = reader.readBool();
      if (hasReminderTime) reminderTime = reader.readString();
    }
    // Backward-compatible optional fields added in MTB-26
    String colorHex = '4C6EAD';
    String iconName = 'fitness_center';
    if (reader.availableBytes > 0) {
      colorHex = reader.readString();
      iconName = reader.readString();
    }
    // Backward-compatible optional fields added in MTB-29
    GoalType goalType = GoalType.days;
    String metricName = '';
    if (reader.availableBytes > 0) {
      final goalTypeIndex = reader.readInt();
      goalType = GoalType.values[goalTypeIndex.clamp(0, GoalType.values.length - 1)];
      metricName = reader.readString();
    }
    return Campaign(
      id: id,
      name: name,
      goal: goal,
      totalDays: totalDays,
      currentDay: currentDay,
      isActive: isActive,
      dayHistory: dayHistory,
      lastCheckInDate: lastCheckInDate,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      colorHex: colorHex,
      iconName: iconName,
      goalType: goalType,
      metricName: metricName,
    );
  }

  @override
  void write(BinaryWriter writer, Campaign obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.goal);
    writer.writeInt(obj.totalDays);
    writer.writeInt(obj.currentDay);
    writer.writeBool(obj.isActive);
    writer.writeList(obj.dayHistory);
    // Backward-compatible optional field added in MTB-11
    writer.writeBool(obj.lastCheckInDate != null);
    if (obj.lastCheckInDate != null) writer.writeString(obj.lastCheckInDate!);
    // Backward-compatible optional fields added in MTB-22
    writer.writeBool(obj.reminderEnabled);
    writer.writeBool(obj.reminderTime != null);
    if (obj.reminderTime != null) writer.writeString(obj.reminderTime!);
    // Backward-compatible optional fields added in MTB-26
    writer.writeString(obj.colorHex);
    writer.writeString(obj.iconName);
    // Optional fields added in MTB-29
    writer.writeInt(obj.goalType.index);
    writer.writeString(obj.metricName);
  }
}
