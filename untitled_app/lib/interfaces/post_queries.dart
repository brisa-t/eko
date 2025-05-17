import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/enums.dart';

Future<List<MapEntry<PostModel, String>>> _getPosts(
    Query<Map<String, dynamic>> baseQuery,
    List<MapEntry<String, String>> list,
    WidgetRef ref) async {
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  final postList = await Future.wait(
    await query.get().then(
          (data) => data.docs.map(
            (raw) async {
              final json = raw.data();
              json['id'] = raw.id;
              json['commentCount'] =
                  await countComments(raw.id); // commentCount;
              final post = PostModel.fromJson(json, LikeState.neutral);
              final likeState =
                  ref.read(currentUserProvider.notifier).getLikeState(raw.id);
              return MapEntry(
                  post.copyWith(likeState: likeState), json['time'] as String);
            },
          ),
        ),
  );
  return postList;
}

Future<(List<MapEntry<String, String>>, bool)> profilePageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref) async {
  final uid = ref.read(currentUserProvider).user.uid;
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('author', isEqualTo: uid)
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final postList = await _getPosts(baseQuery, list, ref);
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  //     .map<Future<Post>>((raw) async {
  //   return Post.fromRaw(raw, AppUser.fromCurrent(locator<CurrentUser>()),
  //       await countComments(raw.postID),
  //       group: (raw.tags.contains('public'))
  //           ? null
  //           : await GroupHandler().getGroupFromId(raw.tags.first),
  //       hasCache: true);
  // }).toList();
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> otherProfilePageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref, String uid) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('author', isEqualTo: uid)
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final postList = await _getPosts(baseQuery, list, ref);
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  //     .map<Future<Post>>((raw) async {
  //   return Post.fromRaw(raw, AppUser.fromCurrent(locator<CurrentUser>()),
  //       await countComments(raw.postID),
  //       group: (raw.tags.contains('public'))
  //           ? null
  //           : await GroupHandler().getGroupFromId(raw.tags.first),
  //       hasCache: true);
  // }).toList();
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> newPageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final postList = await _getPosts(baseQuery, list, ref);
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  //     .map<Future<Post>>((raw) async {
  //   return Post.fromRaw(raw, AppUser.fromCurrent(locator<CurrentUser>()),
  //       await countComments(raw.postID),
  //       group: (raw.tags.contains('public'))
  //           ? null
  //           : await GroupHandler().getGroupFromId(raw.tags.first),
  //       hasCache: true);
  // }).toList();
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}
