import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// An image chosen for a post (already resized / re-encoded by the picker).
@immutable
class PickedImage {
  const PickedImage({required this.bytes, this.name = ''});

  final Uint8List bytes;
  final String name;
}

/// Picks images from the photo library (seam for tests).
abstract interface class CommunityImagePicker {
  /// Up to [limit] images; empty when the user cancels.
  Future<List<PickedImage>> pick({required int limit});
}

/// Longest side of an uploaded image (px) and its JPEG quality.
const kUploadMaxDimension = 1600.0;
const kUploadJpegQuality = 85;

/// [CommunityImagePicker] backed by `image_picker`: the plugin resizes to
/// [kUploadMaxDimension] and re-encodes at [kUploadJpegQuality] (JPEG), so
/// uploads stay well under the 2 MB server limit.
class DeviceImagePicker implements CommunityImagePicker {
  const DeviceImagePicker();

  @override
  Future<List<PickedImage>> pick({required int limit}) async {
    if (limit <= 0) return const [];
    final picker = ImagePicker();
    final List<XFile> files;
    if (limit == 1) {
      final one = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: kUploadMaxDimension,
        maxHeight: kUploadMaxDimension,
        imageQuality: kUploadJpegQuality,
      );
      files = [?one];
    } else {
      files = await picker.pickMultiImage(
        maxWidth: kUploadMaxDimension,
        maxHeight: kUploadMaxDimension,
        imageQuality: kUploadJpegQuality,
        limit: limit,
      );
    }
    return [
      for (final f in files.take(limit))
        PickedImage(bytes: await f.readAsBytes(), name: f.name),
    ];
  }
}
