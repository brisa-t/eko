import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../models/post_handler.dart';

class ViewLikesPageController extends ChangeNotifier {
  final String postId;
  final bool dislikes;
  ViewLikesPageController({required this.postId, this.dislikes = false});

  Future<PaginationGetterReturn> getter(dynamic uid) async {
    return dislikes ? locator<PostsHandling>().getPostDislikes(uid, postId) : locator<PostsHandling>().getPostLikes(uid, postId);
  }

  dynamic startAfterQuery(dynamic user) async {
    user as AppUser;
    return user.uid;
  }
}
