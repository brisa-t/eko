import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
part '../generated/types/activity.freezed.dart';
part '../generated/types/activity.g.dart';

@freezed
abstract class ActivityModel with _$ActivityModel {
  const ActivityModel._();
  const factory ActivityModel({
    @Default('') String sourceUid,
    required String id,
    @JsonKey(name: 'time') required String createdAt,
    @Default(<String>[]) List<String> tags,
    @Default('') String type,
    @Default('') String content,
    @Default('') String path,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  // static Future<PostModel> fromFireStoreDoc(
  //     QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
  //   final json = doc.data();
  //   json['id'] = doc.id;
  //   json['commentCount'] = await countComments(doc.id);
  //   return PostModel.fromJson(json);
  // }
}
