import 'package:fire_base_flutter_chat/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final void Function()? onTap;
  const ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: onTap,
        dense: false,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userProfile.pfpURL!),
        ),
        title: Text(userProfile.name!),
      ),
    );
  }
}
