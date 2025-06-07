import 'package:get_it/get_it.dart';
import '../models/current_user.dart';
import '../models/post_handler.dart';
import '../models/version_control.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<CurrentUser>(() => CurrentUser());
  locator.registerLazySingleton<PostsHandling>(() => PostsHandling());
  locator.registerSingleton<Version>(Version());
}
