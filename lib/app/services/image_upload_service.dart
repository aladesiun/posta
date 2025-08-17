import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:posta/app/services/api_client.dart';

class ImageUploadService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Upload image to Cloudinary using signed upload
  Future<String> uploadImage(File imageFile) async {
    try {
      // Step 1: Get upload signature from server
      final signatureResponse =
          await _apiClient.dio.get('/cloudinary/signature');

      if (signatureResponse.statusCode != 200) {
        throw Exception('Failed to get upload signature');
      }

      final signatureData = signatureResponse.data;
      final timestamp = signatureData['timestamp'];
      final signature = signatureData['signature'];
      final cloudName = signatureData['cloudName'];
      final apiKey = signatureData['apiKey'];
      final folder = signatureData['folder'];

      // Step 2: Upload to Cloudinary
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: 'posta_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      // Add required parameters
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['api_key'] = apiKey;
      request.fields['folder'] = folder;

      // Debug: Log the parameters being sent
      print('Cloudinary upload parameters:');
      print('  timestamp: $timestamp');
      print('  signature: $signature');
      print('  api_key: $apiKey');
      print('  folder: $folder');
      print('  uploadUrl: $uploadUrl');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Cloudinary upload failed: ${response.body}');
      }

      final responseData = json.decode(response.body);
      final imageUrl = responseData['secure_url'] as String;

      print('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Compress image before upload
  Future<File> compressImage(File imageFile) async {
    try {
      // For now, return the original file
      // You can add image compression logic here if needed
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile; // Return original if compression fails
    }
  }
}

class ImageUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageUploadService>(() => ImageUploadService());
  }
}
