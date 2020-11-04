import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klippa_identity_validation_sdk/klippa_identity_validation_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('klippa_identity_validation_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await KlippaIdentityValidationSdk.platformVersion, '42');
  });
}
