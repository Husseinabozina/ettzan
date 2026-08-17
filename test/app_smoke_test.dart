import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic locale resolves to RTL direction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar'), Locale('en')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: _DirectionProbe(),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byType(_DirectionProbe))),
      ui.TextDirection.rtl,
    );
  });
}

class _DirectionProbe extends StatelessWidget {
  const _DirectionProbe();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
