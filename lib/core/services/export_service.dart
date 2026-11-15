import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Renders a widget to PNG and shares it via the system share sheet
/// (which doubles as "save to gallery" on most platforms).
final class ExportService {
  ExportService._();

  /// Renders the current [ScreenshotController] content to PNG bytes at
  /// [pixelRatio]x device pixels (3x ≈ 1080p+ for typical poster widths).
  static Future<Uint8List?> capture(
    ScreenshotController controller, {
    double pixelRatio = 3.0,
  }) =>
      controller.capture(pixelRatio: pixelRatio);

  /// Shares the poster PNG plus optional caption text.
  static Future<void> sharePoster({
    required Uint8List bytes,
    String? text,
    String fileName = 'laporan_atensi.png',
  }) =>
      Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
        text: text,
      );

  /// Copies [text] to the system clipboard.
  static Future<void> copyCaption(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
