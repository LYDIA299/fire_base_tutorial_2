import 'package:fire_base_flutter_chat/models/user_profile.dart';
import 'package:fire_base_flutter_chat/pages/chat_page.dart';
import 'package:fire_base_flutter_chat/services/alert_service.dart';
import 'package:fire_base_flutter_chat/services/auth_service.dart';
import 'package:fire_base_flutter_chat/services/database_service.dart';
import 'package:fire_base_flutter_chat/services/navigation_service.dart';
import 'package:fire_base_flutter_chat/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt<NavigationService>();
    _alertService = _getIt<AlertService>();
    _databaseService = _getIt<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
              onPressed: () async {
                final bool result = await _authService.logout();
                if (result) {
                  _alertService.showToast(
                      text: "Successfully logged out", icon: Icons.check);
                  _navigationService.pushReplacementNamed("/login");
                }
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load data."),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: ((context, index) {
                print(users[index].data().name);
                UserProfile user = users[index].data();
                return ChatTile(
                  userProfile: user,
                  onTap: () async {
                    print("tapped on user chat");
                    final chatExists = await _databaseService.checkChatExists(
                        _authService.user!.uid, user.uid!);
                    if (!chatExists) {
                      await _databaseService.createNewChat(
                        _authService.user!.uid,
                        user.uid!,
                      );
                    }
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(chatUser: user),
                      ),
                    );
                  },
                );
              }),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
