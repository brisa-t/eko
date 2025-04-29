import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/cache_service.dart';

final userCacheProvider = Provider<CacheService<UserModel>>((ref) {
  return CacheService<UserModel>(
    onInsert: (uid) => ref.invalidate(userProvider(uid)),
    keySelector: (user) => user.uid,
    validTime: const Duration(minutes: 3),
  );
});
