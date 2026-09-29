import 'dart:io';

/// Deletes a test temp dir. Windows refuses to remove a directory while a
/// fire-and-forget cache write is still finishing (errno 145), so retry
/// briefly and give up quietly: the OS cleans its temp folder anyway.
Future<void> deleteTempDir(Directory dir) async {
  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
