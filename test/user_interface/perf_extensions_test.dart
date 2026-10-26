import 'package:druid_app/user_interface/perf_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trova lo scorrimento più lungo e lo percorre fino in fondo e ritorno', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView(scrollDirection: Axis.horizontal, children: [for (var i = 0; i < 30; i++) Text('o$i')]),
              ),
              SizedBox(height: 100, child: ListView(children: [for (var i = 0; i < 20; i++) Text('a$i')])),
              Expanded(child: ListView(children: [for (var i = 0; i < 200; i++) Text('b$i')])),
            ],
          ),
        ),
      ),
    );
    final position = mainScrollPosition()!;
    expect(position.axis, Axis.vertical);
    expect(find.text('b0'), findsOneWidget);

    var reachedEnd = false;
    position.addListener(() => reachedEnd |= position.pixels == position.maxScrollExtent);
    final done = scrollThrough(position, rounds: 1, leg: const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await done;
    expect(reachedEnd, isTrue);
    expect(position.pixels, 0);
  });
}
