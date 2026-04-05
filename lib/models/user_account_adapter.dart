import 'package:hive_flutter/hive_flutter.dart';
import 'user_account.dart';

class UserAccountAdapter extends TypeAdapter<UserAccount> {
  @override
  final int typeId = 1;

  @override
  UserAccount read(BinaryReader reader) {
    final email = reader.readString();
    final password = reader.readString();
    return UserAccount(email: email, password: password);
  }

  @override
  void write(BinaryWriter writer, UserAccount obj) {
    writer.writeString(obj.email);
    writer.writeString(obj.password);
  }
}
