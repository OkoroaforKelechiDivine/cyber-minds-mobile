import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:safe_chat/appConfig/manager/theme_manager.dart';

import '../../model/profile_model.dart';
import '../../service/auth_service/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String selectedGender;

  const ProfileScreen({Key? key, required this.selectedGender}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? userName;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? emailAddress;
  bool isLoading = false;

  TextEditingController dateOfBirthController = TextEditingController(); // Add this controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed("/sign_up");
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              _buildProfilePicture(),
              _buildProfileForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    final isMale = widget.selectedGender == 'Male';
    return GestureDetector(
      onTap: _viewImage,
      child: Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.grey,
              backgroundImage: _image != null ? FileImage(_image!) : (isMale ? AssetImage('assets/jpg/male-default-avatar.jpg') : AssetImage('assets/jpg/female-default-avatar.jpg')) as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _getImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.activeButton,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    final greenUnderline = UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.green),
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Username',
              enabledBorder: greenUnderline,
              focusedBorder: greenUnderline,
            ),
            onChanged: (value) {
              setState(() {
                userName = value;
              });
            },
          ),

          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  enabledBorder: greenUnderline,
                  focusedBorder: greenUnderline,
                ),
                controller: dateOfBirthController,
              ),
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Bio',
              enabledBorder: greenUnderline,
              focusedBorder: greenUnderline,
            ),
            onChanged: (value) {
              setState(() {
                lastName = value;
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Hobbies',
              enabledBorder: greenUnderline,
              focusedBorder: greenUnderline,
            ),
            onChanged: (value) {
              setState(() {
                emailAddress = value;
              });
            },
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              if (_validateForm()) {
                setState(() {
                  isLoading = true;
                });
                final profileDTO = ProfileDTO(
                  username: userName!,
                  dateOfBirth: dateOfBirth!,
                  bio: lastName!,
                  profileImageUrl: _image?.path ?? '',
                  hobbies: emailAddress!,
                );

                final result = await AuthApiService.createProfile(
                  profileDTO.username,
                  profileDTO.dateOfBirth.toIso8601String(),
                  profileDTO.bio,
                  profileDTO.profileImageUrl,
                  profileDTO.hobbies,
                  context
                );
                if (result['success'] == true) {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  });
                } else {
                  AuthApiService.showSnackBar(context, result['message']);
                }
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: isLoading ? CircularProgressIndicator(color: AppColors.activeButton) : const Text('Complete'),
          )
        ],
      ),
    );
  }

  bool _validateForm() {
    if (userName == null || userName!.isEmpty) {
      AuthApiService.showSnackBar(context, 'Username is required');
      return false;
    }

    if (dateOfBirth == null) {
      AuthApiService.showSnackBar(context, 'Date of Birth is required');
      return false;
    }

    if (lastName == null || lastName!.isEmpty) {
      AuthApiService.showSnackBar(context, 'Bio is required');
      return false;
    }

    if (emailAddress == null || emailAddress!.isEmpty) {
      AuthApiService.showSnackBar(context, 'Hobbies is required');
      return false;
    }

    return true;
  }

  void _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _viewImage() {
    if (_image != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        dateOfBirth = selectedDate;
        dateOfBirthController.text =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
  }
}
