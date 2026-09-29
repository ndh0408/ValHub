import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/image_source.dart';

import '../community_test_env.dart' show jpegBytes;

/// Client-side image pre-processing: the photo picker downsizes to 1600 px
/// on the long side and re-encodes JPEG at 85 %. Nothing else is stripped
/// or rewritten by the app: the server removes EXIF and other metadata
/// itself (and keeps only the orientation).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/image_picker');
  late Directory dir;
  late File photo;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    dir = Directory.systemTemp.createTempSync('valvn_picker_');
    photo = File('${dir.path}/photo.jpg')..writeAsBytesSync(jpegBytes(200));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'pickImage' => photo.path,
            'pickMultiImage' => [photo.path, photo.path],
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    dir.deleteSync(recursive: true);
  });

  test('the limits: 1600 px, JPEG quality 85, well under the server cap', () {
    expect(kUploadMaxDimension, 1600);
    expect(kUploadJpegQuality, 85);
    expect(CommunityApi.maxMediaBytes, 2 * 1024 * 1024);
  });

  test('a single pick asks the plugin for 1600 px at quality 85', () async {
    final picked = await const DeviceImagePicker().pick(limit: 1);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'pickImage');
    final args = calls.single.arguments as Map<Object?, Object?>;
    expect(args['maxWidth'], 1600.0);
    expect(args['maxHeight'], 1600.0);
    expect(args['imageQuality'], 85);
    // The gallery (never the camera).
    expect(args['source'], 1);
    expect(picked, hasLength(1));
    expect(picked.single.bytes, photo.readAsBytesSync());
    expect(picked.single.name, endsWith('photo.jpg'));
  });

  test('a multi pick uses the same limits and the free slots', () async {
    final picked = await const DeviceImagePicker().pick(limit: 3);

    expect(calls, hasLength(1));
    expect(calls.single.method, 'pickMultiImage');
    final args = calls.single.arguments as Map<Object?, Object?>;
    expect(args['maxWidth'], 1600.0);
    expect(args['maxHeight'], 1600.0);
    expect(args['imageQuality'], 85);
    expect(args['limit'], 3);
    expect(picked, hasLength(2));
  });

  test('bytes are handed over untouched (no extra stripping)', () async {
    final original = photo.readAsBytesSync();
    final picked = await const DeviceImagePicker().pick(limit: 1);
    expect(picked.single.bytes, original);
  });

  test('no free slot: the library is not even opened', () async {
    expect(await const DeviceImagePicker().pick(limit: 0), isEmpty);
    expect(calls, isEmpty);
  });

  test('cancelling gives an empty list', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
    expect(await const DeviceImagePicker().pick(limit: 1), isEmpty);
    expect(await const DeviceImagePicker().pick(limit: 2), isEmpty);
  });
}
