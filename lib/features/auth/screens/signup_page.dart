import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../../core/models/user_model.dart';
import '../../../core/typography/app_text_styles.dart';
import '../../../core/services/cloudinary_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int _currentStep = 1;
  bool _isLoading = false;

  // Step 1 Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _dateOfBirth;

  // Step 2 Controllers
  final _usernameController = TextEditingController();
  String? _profileImagePath;

  // Password Controller
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _dateOfBirth = pickedDate);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final int fileSizeInMB = await imageFile.length() ~/ (1024 * 1024);

        if (fileSizeInMB > 25) {
          _showError('Image size must be less than 25 MB');
          return;
        }

        // Crop the image
        await _cropImage(pickedFile.path);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Theme.of(context).colorScheme.primary,
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
        setState(() => _profileImagePath = croppedFile.path);
      }
    } catch (e) {
      _showError('Error cropping image: $e');
    }
  }

  bool _validateStep1() {
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name');
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name');
      return false;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (_dateOfBirth == null) {
      _showError('Please select your date of birth');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_usernameController.text.isEmpty) {
      _showError('Please enter a username');
      return false;
    }
    if (_usernameController.text.length < 2) {
      _showError('Username must be at least 2 characters');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);

    try {
      // 1. Create auth user with email & password in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // 2. Upload profile image to Cloudinary if provided
      String? profilePictureUrl;
      if (_profileImagePath != null) {
        profilePictureUrl = await CloudinaryService().uploadImage(
          _profileImagePath!,
        );
        if (profilePictureUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload profile picture'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Continue without profile picture
        }
      }

      // 3. Create the UserModel with Cloudinary URL
      final newUser = UserModel(
        userId: userCredential.user!.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: '@${_usernameController.text.trim()}',
        dateOfBirth: _dateOfBirth,
        profilePicture: profilePictureUrl, // Store Cloudinary URL
        followersCount: 0,
        followingCount: 0,
      );

      // 4. Save the new UserModel to 'tbl_users' in Firestore
      await FirebaseFirestore.instance
          .collection('tbl_users')
          .doc(newUser.userId)
          .set(newUser.toMap());

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Signup Successful!")));
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ============ HEADER SECTION ============
                // NEST Logo
                SizedBox(
                  height: 80,
                  child: Image.asset(
                    'resources/LOGO.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'NEST',
                        style: AppTextStyles.heading(
                          context,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Step Indicator
                Text(
                  'Step $_currentStep of 2',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subheading(
                    context,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Step Title
                Text(
                  _getStepTitle(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(context, fontSize: 24),
                ),
                const SizedBox(height: 40),

                // ============ FORM SECTION ============
                if (_currentStep == 1) ...[
                  _buildStep1Form(),
                ] else if (_currentStep == 2) ...[
                  _buildStep2Form(),
                ],

                const SizedBox(height: 40),

                // ============ BUTTON SECTION ============
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button (only on page 2)
                    if (_currentStep > 1)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _currentStep--),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back'),
                      ),
                    // Spacer to push next button to right on page 1
                    if (_currentStep == 1) const Spacer(),
                    // Next Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        _currentStep == 2 ? 'Create Account' : 'Next',
                        style: const TextStyle(fontSize: 14),
                      ),
                      icon: _isLoading
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
                          : const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.body(context),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Login',
                        style: AppTextStyles.body(
                          context,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Create Your Account';
      case 2:
        return 'Choose Your Identity';
      default:
        return '';
    }
  }

  Widget _buildStep1Form() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'John',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Doe',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'john@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildDateOfBirthField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'At least 6 characters',
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildStep2Form() {
    return Column(
      children: [
        _buildUsernameField(),
        const SizedBox(height: 24),
        _buildProfilePictureUpload(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String prefix = '',
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixText: prefix.isNotEmpty ? '$prefix ' : null,
            counterText: '',
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: AppTextStyles.subheading(context, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Non-editable @ prefix
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                '@',
                style: AppTextStyles.body(context, fontSize: 16),
              ),
            ),
            // Editable username field
            Expanded(
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'yourname',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
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
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: AppTextStyles.subheading(context, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _dateOfBirth == null
                  ? 'Select Date'
                  : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
              style: _dateOfBirth == null
                  ? AppTextStyles.body(context, fontSize: 16).copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    )
                  : AppTextStyles.body(context, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture (Optional)',
          style: AppTextStyles.subheading(context, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Center(
          child: _profileImagePath == null
              ? Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickProfileImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.file(
                          File(_profileImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error loading image',
                                    style: AppTextStyles.body(
                                      context,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _profileImagePath = null),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _handleNextStep() {
    if (_currentStep == 1 && _validateStep1()) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_validateStep2()) {
        _handleSignup();
      }
    }
  }
}
