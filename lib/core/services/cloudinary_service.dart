import 'dart:io';
import 'package:http/http.dart' as http;

/// Service to handle Cloudinary image uploads using HTTP
class CloudinaryService {
  static const String _uploadPreset = 'fmygcvu3'; // Your upload preset
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/demxfnkhl/image/upload';

  static final CloudinaryService _instance = CloudinaryService._internal();

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal();

  /// Upload image to Cloudinary using HTTP
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadImage(String imagePath) async {
    try {
      final file = File(imagePath);

      if (!file.existsSync()) {
        throw Exception('File does not exist: $imagePath');
      }

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = _uploadPreset;

      // Add folder to organize uploads
      request.fields['folder'] = 'nest_app/users';

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse response
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        // Extract secure_url from response
        // Response is JSON like: {"secure_url": "https://...", ...}
        final secureUrlPattern = RegExp(r'"secure_url":"([^"]+)"');
        final match = secureUrlPattern.firstMatch(responseString);

        if (match != null && match.group(1) != null) {
          return match.group(1);
        } else {
          throw Exception('Could not extract URL from response');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
    final urls = <String>[];

    for (final path in imagePaths) {
      final url = await uploadImage(path);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }
}
