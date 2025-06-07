import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/online_status.dart';
import 'package:flutter_udid/flutter_udid.dart';

part '../generated/providers/presence_provider.g.dart';

@riverpod
class Presence extends _$Presence {
  @override
  OnlineStatus build() {
    _init();
    return const OnlineStatus(online: false, id: '', lastChanged: 0);
  }

  void _init() async {
    await setOnline();
    final uid = ref.read(authProvider).uid!;
    DatabaseReference onlineRef = FirebaseDatabase.instance.ref('status/$uid');
    String deviceUid = await FlutterUdid.udid;
    onlineRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        OnlineStatus status = OnlineStatus.fromJson(jsonData);
        bool valid = status.id == deviceUid;
        if (!status.online) validateSession();
        state = state.copyWith(
            online: status.online,
            lastChanged: status.lastChanged,
            valid: valid);
      }
    });

    Map<String, dynamic> offline = {
      'online': false,
    };

    onlineRef.onDisconnect().update(offline);
  }

  Future<void> setOnline() async {
    final uid = ref.read(authProvider).uid!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('status/$uid');
    Map<String, dynamic> isOnlineForDatabase = {
      'online': true,
      'last_changed': ServerValue.timestamp,
    };

    final data = await dbRef.get();
    if (data.exists) {
      final deviceId = await FlutterUdid.udid;
      final jsonData = Map<String, dynamic>.from(data.value as Map);
      OnlineStatus status = OnlineStatus.fromJson(jsonData);
      // if offline and and id is not the device id, we can validate
      if (!status.online && status.id != deviceId) {
        isOnlineForDatabase.addAll({'id': deviceId});
      }
    }

    await dbRef.update(isOnlineForDatabase);
  }

  Future<void> validateSession() async {
    final uid = ref.read(authProvider).uid!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('status/$uid');
    String deviceUid = await FlutterUdid.udid;

    Map<String, dynamic> isOnlineForDatabase = {
      'online': true,
      'id': deviceUid,
      'last_changed': ServerValue.timestamp,
    };
    await dbRef.set(isOnlineForDatabase);
  }
}
