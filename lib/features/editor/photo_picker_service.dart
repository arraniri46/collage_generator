import 'package:image_picker/image_picker.dart';

/// Abstract photo source picker so tests can fake platform channels.
abstract class PhotoPickerService {
  const PhotoPickerService();

  /// Picks a photo from the device gallery, returns the local file path
  /// (null when the user cancels).
  Future<String?> pickFromGallery({int? imageQuality});

  /// Takes a photo with the device camera, returns the local file path
  /// (null when the user cancels).
  Future<String?> takeWithCamera({int? imageQuality});
}

/// Default implementation backed by [ImagePicker].
final class ImagePickerService implements PhotoPickerService {
  ImagePickerService();

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickFromGallery({int? imageQuality}) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality ?? 85,
    );
    return xfile?.path;
  }

  @override
  Future<String?> takeWithCamera({int? imageQuality}) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality ?? 85,
    );
    return xfile?.path;
  }
}

