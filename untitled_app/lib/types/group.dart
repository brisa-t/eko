import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/group.freezed.dart';
part '../generated/types/group.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
  @JsonSerializable(explicitToJson: true)
  const factory GroupModel({
    required String id,
    required String name,
    required String description,
    required String lastActivity,
    required final String createdOn,
    required String icon,
    required List<String> members,
    required List<String> notSeen,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json, String id) {
    return GroupModel(
        createdOn: json['createdOn'],
        name: json['name'],
        lastActivity: json['lastActivity'],
        icon: json['icon'],
        members: json['members'].cast<String>(),
        notSeen: (json['notSeen'] ?? []).cast<String>(),
        description: json['description'],
        id: id);
  }
  // Map<String, dynamic> toMap() {
  //   Map<String, dynamic> map = {};
  //   map['name'] = name;
  //   map['lastActivity'] = lastActivity;

  //   map['members'] = members;
  //   map['description'] = description;
  //   map['icon'] = icon;
  //   map['createdOn'] = createdOn;
  //   return map;
  // }
}
