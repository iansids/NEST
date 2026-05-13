import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../../core/models/user_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../../../core/services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  String? _newProfileImagePath;
  String? _currentProfilePictureUrl;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentProfilePictureUrl = widget.user.profilePicture;

    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    // Strip the leading @ for editing
    final rawUsername = widget.user.username.startsWith('@')
        ? widget.user.username.substring(1)
        : widget.user.username;
    _usernameController = TextEditingController(text: rawUsername);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final sizeInMB = await file.length() ~/ (1024 * 1024);
      if (sizeInMB > 25) {
        _showError('Image size must be less than 25 MB');
        return;
      }
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() => _newProfileImagePath = croppedFile.path);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  bool _validate() {
    if (_firstNameController.text.trim().isEmpty) {
      _showError('First name cannot be empty');
      return false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Last name cannot be empty');
      return false;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showError('Username cannot be empty');
      return false;
    }
    if (_usernameController.text.trim().length < 2) {
      _showError('Username must be at least 2 characters');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);

    try {
      String? profilePictureUrl = _currentProfilePictureUrl;

      // Upload new profile picture if one was selected
      if (_newProfileImagePath != null) {
        setState(() => _isUploadingImage = true);
        profilePictureUrl = await CloudinaryService().uploadImage(
          _newProfileImagePath!,
        );
        setState(() => _isUploadingImage = false);

        if (profilePictureUrl == null) {
          _showError('Failed to upload profile picture');
          setState(() => _isSaving = false);
          return;
        }
      }

      final updates = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': '@${_usernameController.text.trim()}',
        'bio': _bioController.text.trim(),
        'profile_picture': profilePictureUrl,
      };

      await FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(widget.user.userId)
          .update(updates);

      if (mounted) {
        // Return updated user to the caller
        final updatedUser = UserModel(
          userId: widget.user.userId,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: widget.user.email,
          username: '@${_usernameController.text.trim()}',
          profilePicture: profilePictureUrl,
          bio: _bioController.text.trim(),
          dateOfBirth: widget.user.dateOfBirth,
          followersCount: widget.user.followersCount,
          followingCount: widget.user.followingCount,
          createdAt: widget.user.createdAt,
        );
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      _showError('Failed to save changes: $e');
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.heading(context, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.subheading(
                      context,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture
            Center(
              child: GestureDetector(
                onTap: _isSaving ? null : _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: _buildAvatar(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // First name
            _buildField(
              label: 'First Name',
              controller: _firstNameController,
              hint: 'John',
            ),
            const SizedBox(height: 20),

            // Last name
            _buildField(
              label: 'Last Name',
              controller: _lastNameController,
              hint: 'Doe',
            ),
            const SizedBox(height: 20),

            // Username
            _buildUsernameField(),
            const SizedBox(height: 20),

            // Bio
            _buildField(
              label: 'Bio',
              controller: _bioController,
              hint: 'Tell people about yourself...',
              maxLines: 4,
              maxLength: 150,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTextStyles.subheading(
                          context,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (_newProfileImagePath != null) {
      return ClipOval(
        child: Image.file(
          File(_newProfileImagePath!),
          fit: BoxFit.cover,
          width: 104,
          height: 104,
        ),
      );
    }
    if (_currentProfilePictureUrl != null) {
      return ClipOval(
        child: Image.network(
          _currentProfilePictureUrl!,
          fit: BoxFit.cover,
          width: 104,
          height: 104,
          errorBuilder: (_, _, _) => Icon(
            Icons.person,
            size: 52,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 52,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subheading(context, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterStyle: AppTextStyles.body(
              context,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: AppTextStyles.body(context),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Username', style: AppTextStyles.subheading(context, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                '@',
                style: AppTextStyles.body(context, fontSize: 16),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'yourname',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  counterText: '',
                ),
                style: AppTextStyles.body(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
