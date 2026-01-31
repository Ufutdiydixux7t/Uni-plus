import 'dart:io';
import 'package:file_picker/file_picker.dart';

class PickedFileModel {
  final File file;
  final String name;
  final String size;
  final String extension;

  PickedFileModel({
    required this.file,
    required this.name,
    required this.size,
    required this.extension,
  });
}

class FilePickerService {
  static Future<PickedFileModel?> pickFile({
    required List<String> allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.single;
        
        // Calculate size in MB or KB
        String sizeStr;
        double sizeInMb = file.size / (1024 * 1024);
        if (sizeInMb < 1) {
          sizeStr = '${(file.size / 1024).toStringAsFixed(2)} KB';
        } else {
          sizeStr = '${sizeInMb.toStringAsFixed(2)} MB';
        }

        return PickedFileModel(
          file: File(file.path!),
          name: file.name,
          size: sizeStr,
          extension: file.extension ?? '',
        );
      }
    } catch (e) {
      // Log error in production
      print('Error picking file: $e');
    }
    return null;
  }

  static List<String> getExtensionsFor(String category) {
    switch (category.toLowerCase()) {
      case 'summaries':
      case 'assignments':
        return ['pdf', 'jpg', 'jpeg', 'png'];
      case 'materials':
        return ['pdf'];
      case 'grades':
        return ['xlsx'];
      default:
        return ['pdf'];
    }
  }
}
