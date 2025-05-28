import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/edit_profile_text_field.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/user.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/profile_avatar.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  late final TextEditingController usernameController;

  @override
  void initState() {
    final user = ref.read(currentUserProvider).user;
    nameController = TextEditingController(text: user.name);
    bioController = TextEditingController(text: user.bio);
    usernameController = TextEditingController(text: user.username);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void _showUserNameReqs() {
    showMyDialog(
        AppLocalizations.of(context)!.invalidUserName,
        AppLocalizations.of(context)!.usernameReqs,
        [AppLocalizations.of(context)!.ok],
        [context.pop],
        context);
  }

  void _savePressed(UserModel user) {
    final name = nameController.text != user.name ? nameController.text : null;
    final bio = bioController.text != user.bio ? bioController.text : null;
    ref.read(currentUserProvider.notifier).editProfile(name: name, bio: bio);
    context.pop();
  }

  void _showWarning() {
    showMyDialog(
        AppLocalizations.of(context)!.exitEditProfileTitle,
        AppLocalizations.of(context)!.exitEditProfileBody,
        [
          AppLocalizations.of(context)!.exit,
          AppLocalizations.of(context)!.stay
        ],
        [
          () {
            context.pop();
            context.pop();
          },
          context.pop
        ],
        context);
  }

  bool _shouldShowSave(UserModel user) {
    final bioChanged = bioController.text != user.bio;
    final nameChanged = nameController.text != user.name;
    return bioChanged || nameChanged;
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final user = ref.watch(currentUserProvider).user;

    final height = MediaQuery.sizeOf(context).height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, Object? result) {
        if (didPop) return;
        if (!_shouldShowSave(user)) context.pop();
        _showWarning();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      AppLocalizations.of(context)!.editProfile,
                      //AppLocalizations.of(context)!.save,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([bioController, nameController]),
                      builder: (context, _) {
                        if (_shouldShowSave(user)) {
                          return TextButton(
                            child: Text(
                              AppLocalizations.of(context)!.save,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onPressed: () => _savePressed(user),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          SizedBox(
                            height: width * 0.4,
                            width: width * 0.4,
                            // child: ClipOval(
                            //     child: prov.Provider.of<EditProfileController>(
                            //                     context,
                            //                     listen: true)
                            //                 .newProfileImage !=
                            //             null
                            //         ? Image.file(
                            //             fit: BoxFit.fill,
                            //             prov.Provider.of<EditProfileController>(
                            //                     context,
                            //                     listen: true)
                            //                 .newProfileImage!)
                            //         : ProfileAvatar(
                            //             url:
                            //                 prov.Provider.of<EditProfileController>(
                            //                         context,
                            //                         listen: true)
                            //                     .profileImage)),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15)),
                              onPressed: () {},
                              // prov.Provider.of<EditProfileController>(
                              //         context,
                              //         listen: false)
                              //     .editProfileImagePressed(),
                              child: const Icon(
                                Icons.mode,
                                size: 25,
                              ))
                          // const Image(
                          //   image: AssetImage('images/edit.png'),
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
                ProfileInputFeild(
                  controller: nameController,
                  label: AppLocalizations.of(context)!.name,
                  maxLength: c.maxNameChars,
                ),
                SizedBox(height: height * 0.01),
                ProfileInputFeild(
                  controller: bioController,
                  label: AppLocalizations.of(context)!.bioTitle,
                  maxLength: c.maxBioChars,
                  inputType: TextInputType.multiline,
                ),
                SizedBox(height: height * 0.01),
                // ProfileInputFeild(
                //   onChanged: (s) => prov.Provider.of<EditProfileController>(
                //           context,
                //           listen: false)
                //       .onUsernameChanged(s),
                //   focus: prov.Provider.of<EditProfileController>(context,
                //           listen: false)
                //       .usernameFocus,
                //   label: AppLocalizations.of(context)!.userName,
                //   controller: usernameController,
                //   inputType: TextInputType.text,
                //   //maxLength: c.maxUsernameChars,
                // ),
                // if (usernameController.text != '')
                //   Row(
                //     children: [
                //       const SizedBox(width: 5),
                //       prov.Consumer<EditProfileController>(
                //         builder: (context, signUpController, _) =>
                //             signUpController.validUsername
                //                 ? signUpController.isChecking
                //                     ? Padding(
                //                         padding: const EdgeInsets.only(top: 5),
                //                         child: Container(
                //                           alignment: Alignment.centerRight,
                //                           width: width * 0.05,
                //                           height: width * 0.05,
                //                           child:
                //                               const CircularProgressIndicator(),
                //                         ))
                //                     : signUpController.availableUsername
                //                         ? Padding(
                //                             padding:
                //                                 const EdgeInsets.only(top: 5),
                //                             child: Text(
                //                               AppLocalizations.of(context)!
                //                                   .available,
                //                               style: TextStyle(
                //                                   color: Theme.of(context)
                //                                       .colorScheme
                //                                       .primary),
                //                             ),
                //                           )
                //                         : Padding(
                //                             padding:
                //                                 const EdgeInsets.only(top: 5),
                //                             child: Text(
                //                               AppLocalizations.of(context)!
                //                                   .usernameInUse,
                //                               style: TextStyle(
                //                                   color: Theme.of(context)
                //                                       .colorScheme
                //                                       .error),
                //                             ),
                //                           )
                //                 : Row(
                //                     mainAxisSize: MainAxisSize.min,
                //                     children: [
                //                       Text(
                //                         AppLocalizations.of(context)!
                //                             .invalidUserName,
                //                         style: TextStyle(
                //                             color: Theme.of(context)
                //                                 .colorScheme
                //                                 .error),
                //                       ),
                //                       IconButton(
                //                           onPressed: () {
                //                             _showUserNameReqs();
                //                           },
                //                           icon: const Icon(
                //                               Icons.help_outline_outlined))
                //                     ],
                //                   ),
                //       )
                //     ],
                //   ),
                SizedBox(
                  height: height * 0.5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
