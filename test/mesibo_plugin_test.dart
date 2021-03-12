import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesibo_plugin/mesibo_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('mesibo_plugin');

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
    expect(await MesiboPlugin.platformVersion, '42');
  });
}
