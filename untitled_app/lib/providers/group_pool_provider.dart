import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/types/group.dart';
import 'package:untitled_app/utilities/cache_service.dart';

part '../generated/providers/group_pool_provider.g.dart';

@Riverpod(keepAlive: true)
PoolService<GroupModel> groupPool(Ref ref) {
  return PoolService<GroupModel>(
    onInsert: (id) {
      if (ref.exists(groupProvider(id))) {
        ref.invalidate(groupProvider(id));
      }
    },
    keySelector: (group) => group.id,
    validTime: const Duration(minutes: 3),
  );
}
