import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';

part '../generated/providers/nav_bar_provider.g.dart';
@Riverpod(keepAlive: true)
class NavBar extends _$NavBar {
	@override
  bool build() {
    return true;
  }

  disable() {
    state = false;
  }

  enable() {
    state = true;
  }
}
