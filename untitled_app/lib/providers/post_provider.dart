import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_cache_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/enums.dart';
// Necessary for code-generation to work
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post {
  Timer? _disposeTimer;
  @override
  Future<PostModel> build(String id) async {
    // *** This block is for lifecycle management *** //
    // Keep provider alive
    final link = ref.keepAlive();
    ref.onCancel(() {
      // Start a 3-minute countdown when the last listener goes away
      _disposeTimer = Timer(const Duration(minutes: 3), () {
        link.close();
      });
    });
    ref.onResume(() {
      // Cancel the timer if a listener starts again
      _disposeTimer?.cancel();
    });
    ref.onDispose(() {
      // ckean up if the provider is somehow disposed
      _disposeTimer?.cancel();
    });
    // ********************************************* //

    Future<int> countComments(String postId) {
      return FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .count()
          .get()
          .then((value) => value.count ?? 0, onError: (e) => 0);
    }

    final cacheValue = ref.read(postCacheProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }

    final postsRef = FirebaseFirestore.instance.collection('posts');
    final data = await Future.wait([postsRef.doc(id).get(), countComments(id)]);
    final postData = data[0] as DocumentSnapshot<Map<String, dynamic>>;
    final commentCount = data[1] as int;

    if (postData.data() == null) {
      throw Exception('Failed to load');
    }

    final json = postData.data()!;
    json['id'] = id;
    json['commentCount'] = commentCount;

    return PostModel.fromJson(
        json, ref.read(currentUserProvider.notifier).getLikeState(id));
  }

  Future<void> addLike() async {
		final prevState = await future;
    if (prevState.likeState == LikeState.isLiked) {
			return;
		}
      try {
        final firestore = FirebaseFirestore.instance;
        final user = ref.read(currentUserProvider).user.uid;
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.likedPosts':
                FieldValue.arrayUnion([prevState.id])
          }),
               firestore
                  .collection('posts')
                  .doc(prevState.id)
                  .update({'likes': FieldValue.increment(1)})
                      ]);

          likedPosts.add(postId);

        stateIsLiking = false;
        return true;
      } catch (e) {
        stateIsLiking = false;
        return false;
      }
    } else {
      return false;
    }
  }
}
