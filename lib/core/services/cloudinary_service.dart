import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _uploadPreset = 'fmygcvu3';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/demxfnkhl/image/upload';

  static final CloudinaryService _instance = CloudinaryService._internal();

  factory CloudinaryService() => _instance;

  CloudinaryService._internal();

  Future<String?> uploadImage(String imagePath, {String folder = 'nest_app/users'}) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('File does not exist: $imagePath');
      }

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final body = String.fromCharCodes(bytes);
        final match = RegExp(r'"secure_url":"([^"]+)"').firstMatch(body);
        if (match != null && match.group(1) != null) {
          return match.group(1);
        }
        throw Exception('Could not extract URL from response');
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(
    List<String> imagePaths, {
    String folder = 'nest_app/posts',
  }) async {
    final urls = <String>[];
    for (final path in imagePaths) {
      final url = await uploadImage(path, folder: folder);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}
