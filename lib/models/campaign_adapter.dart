import 'package:hive_flutter/hive_flutter.dart';
import 'campaign.dart';

class CampaignAdapter extends TypeAdapter<Campaign> {
  @override
  final int typeId = 0;

  @override
  Campaign read(BinaryReader reader) {
    return Campaign(
      id: reader.readString(),
      name: reader.readString(),
      goal: reader.readString(),
      totalDays: reader.readInt(),
      currentDay: reader.readInt(),
      isActive: reader.readBool(),
      dayHistory: reader.readList().cast<bool>(),
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
  }
}
