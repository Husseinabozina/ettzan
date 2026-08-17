import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Arabic translation catalog contains the app name', () async {
    final catalog = jsonDecode(
      await rootBundle.loadString('assets/translations/ar.json'),
    ) as Map<String, dynamic>;

    expect(catalog['appName'], 'اتزان');
  });

  test('English translation catalog contains the app name', () async {
    final catalog = jsonDecode(
      await rootBundle.loadString('assets/translations/en.json'),
    ) as Map<String, dynamic>;

    expect(catalog['appName'], 'Etzan');
  });
}
