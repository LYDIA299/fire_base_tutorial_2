import 'dart:io';

import 'package:fire_base_flutter_chat/consts.dart';
import 'package:fire_base_flutter_chat/models/user_profile.dart';
import 'package:fire_base_flutter_chat/services/alert_service.dart';
import 'package:fire_base_flutter_chat/services/auth_service.dart';
import 'package:fire_base_flutter_chat/services/database_service.dart';
import 'package:fire_base_flutter_chat/services/media_service.dart';
import 'package:fire_base_flutter_chat/services/navigation_service.dart';
import 'package:fire_base_flutter_chat/services/storage_service.dart';
import 'package:fire_base_flutter_chat/widgets/custom_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  String? email, password, name;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  File? _selectedImage;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt<NavigationService>();
    _alertService = _getIt<AlertService>();
    _mediaService = _getIt<MediaService>();
    _storageService = _getIt<StorageService>();
    _databaseService = _getIt<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: Column(
          children: [
            _headerText(),
            if (!isloading) _registerForm(),
            if (!isloading) _registerButton(),
            if (!isloading) _createAnAccountLink(),
            if (isloading)
              const Expanded(
                  child: Center(
                child: CircularProgressIndicator(),
              ))
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomFormField(
              labelText: "Name",
              hintText: "Enter your name",
              validationRegEx: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Email",
              hintText: "Enter email",
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormField(
              labelText: "Password",
              hintText: "Enter password",
              obscureText: false,
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            _selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: _selectedImage != null
            ? FileImage(_selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          setState(() {
            isloading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                _selectedImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                print("done with signup");
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: _selectedImage!, uid: _authService.user!.uid);
                if (pfpURL != null) {
                  print("got the image");
                  await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                          uid: _authService.user!.uid,
                          name: name,
                          pfpURL: pfpURL));
                  _alertService.showToast(
                      text: "User registered successfully!", icon: Icons.check);
                } else {
                  throw Exception("Unable to upload user profile image");
                }
                _navigationService.goBack();
                _navigationService.pushReplacementNamed("/home");
              } else {
                throw Exception("Unable to register user");
              }
            }
          } catch (e) {
            _alertService.showToast(
                text: "Failed to register, Please try again",
                icon: Icons.error);
          }
          setState(() {
            isloading = false;
          });
        },
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            _navigationService.goBack();
          },
          child: const Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ));
  }
}
