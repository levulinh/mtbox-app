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
    return Campaign(
      id: id,
      name: name,
      goal: goal,
      totalDays: totalDays,
      currentDay: currentDay,
      isActive: isActive,
      dayHistory: dayHistory,
      lastCheckInDate: lastCheckInDate,
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
  }
}
