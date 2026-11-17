import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Abstract photo source picker so tests can fake platform channels.
abstract class PhotoPickerService {
  const PhotoPickerService();

  /// Picks a photo from the device gallery, returns a **permanent** local
  /// file path (null when the user cancels).
  Future<String?> pickFromGallery({int? imageQuality});

  /// Takes a photo with the device camera, returns a **permanent** local
  /// file path (null when the user cancels).
  Future<String?> takeWithCamera({int? imageQuality});
}

/// Default implementation backed by [ImagePicker].
///
/// [ImagePicker] stores its (compressed) output in the app **cache**
/// directory, which the OS may clear at any time. To make saved reports
/// survive, every picked photo is copied into
/// `<application documents>/photos/` and that permanent path is returned.
final class ImagePickerService implements PhotoPickerService {
  ImagePickerService();

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickFromGallery({int? imageQuality}) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality ?? 85,
    );
    return _persist(xfile);
  }

  @override
  Future<String?> takeWithCamera({int? imageQuality}) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality ?? 85,
    );
    return _persist(xfile);
  }

  /// Copies the picked cache file into the documents directory and returns
  /// the permanent path. Falls back to the original path if the copy fails.
  Future<String?> _persist(XFile? xfile) async {
    if (xfile == null) return null;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docs.path}/photos');
      if (!photosDir.existsSync()) {
        photosDir.createSync(recursive: true);
      }
      final ext = xfile.name.contains('.')
          ? xfile.name.substring(xfile.name.lastIndexOf('.'))
          : '.jpg';
      final permanentPath =
          '${photosDir.path}/${DateTime.now().microsecondsSinceEpoch}$ext';
      await File(xfile.path).copy(permanentPath);
      // Best-effort: remove the temporary cache file.
      final cacheFile = File(xfile.path);
      if (cacheFile.existsSync()) cacheFile.deleteSync();
      return permanentPath;
    } catch (_) {
      // Copy failed — at least return the original (cache) path.
      return xfile.path;
    }
  }
}

