library slim_vendor_app.abortable_test;

import 'dart:async';
import 'package:test/test.dart' hide test;
import 'package:test/test.dart' as _test show test;
import 'package:test/src/backend/declarer.dart' show Declarer;
import 'package:test/src/backend/invoker.dart' show Invoker;

export 'package:test/test.dart' hide test;

Map<Declarer, bool> abortByDeclarer = <Declarer, bool>{};

bool shouldContinue() {
  return abortByDeclarer[Declarer.current] ?? true;
}

void abort() {
  setAbortable();
  abortByDeclarer[Declarer.current] = false;
}

void setAbortable() {
  abortByDeclarer[Declarer.current] = true;
}

void test(description, body(),
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform}) {
  _test.test(description.toString(), () async {
    StreamSubscription sub = Invoker.current.liveTest.onError.listen((AsyncError err) {
      if (abortByDeclarer.containsKey(Declarer.current)) {
        abort();
      }
    });
    await body();
    sub.cancel();
  },
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags);
}

/// Creates a group of tests.
///
/// The difference between this and [group] is that the execution of
/// tests can be aborted by calling [abort] anywhere in the tests
void abortableGroup(description, body(),
    {String testOn,
    Timeout timeout,
    skip,
    tags,
    Map<String, dynamic> onPlatform}) {
  group(description, () {
    setUpAll(() {
      setAbortable();
    });
    setUp(() {
      expect(shouldContinue(), true, reason: 'Previous test indicated that group execution should halt.');
    });
    body();
  }, testOn: testOn,
      timeout: timeout,
      skip: skip,
      tags: tags,
      onPlatform: onPlatform);
}
