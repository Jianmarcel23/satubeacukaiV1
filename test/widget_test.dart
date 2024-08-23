import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satubeacukai/main.dart'; // Sesuaikan dengan jalur ke file main.dart Anda

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Asumsikan currentUserId adalah string dummy
    const String currentUserId = 'dummyUserId';

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: MainScreen(currentUserId: currentUserId),
    ));

    // Verifikasi bahwa waktu awalnya ditampilkan dengan benar (harus disesuaikan dengan format waktu)
    expect(find.textContaining('Current Time'), findsOneWidget);
    expect(find.textContaining('Check In'), findsOneWidget);

    // Tap tombol 'Check In' dan trigger frame
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verifikasi bahwa tombol 'Check Out' muncul setelah check-in
    expect(find.text('Check In'), findsNothing);
    expect(find.text('Check Out'), findsOneWidget);
  });
}
