library slim_vendor_app.test;
//java -jar selenium-standalone-server.jar -Dwebdriver.chrome.driver=chromedriver.exe

@TestOn('vm')
import 'dart:io';
import 'dart:async';
import 'package:webdriver/io.dart' hide createDriver;
import 'package:webdriver/support/async.dart';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

import 'src/abortable_test.dart';
import 'src/util.dart';

import 'test_config.dart';

part 'e2e/token_handling.dart';
part 'e2e/slimview.dart';

Logger logger = new Logger('SlimTests');
QueryWebDriver driver;

main() async {
  Map capabilities = Capabilities.chrome
    ..addAll({
      Capabilities.loggingPrefs: {LogType.performance: LogLevel.severe},
      'chromeOptions': {
        'args': ['incognito']
      }
    });

  setUpAll(() async {
    driver = await createDriver(desired: capabilities);
  });
  tearDownAll(() {
    driver.quit();
  });
  tearDown(() async {
    Iterable<LogEntry> entries = await driver.logs.get(LogType.browser)
        .where((LogEntry entry) => !entry.message.contains('favicon')) // ignore favicon errors
        .toList();
    // take a screenshot
    if (entries.length > 0) {
      entries.forEach((LogEntry entry) {
        logger.fine('BrowserLog | ${entry.toString()}');
      });
      String logFileName = generateFilename();
      String normalizedDirname = path.absolute('test', 'captures');
      await screenShot(driver, path.join(normalizedDirname, '$logFileName.png'));
      new File(path.join(normalizedDirname, '$logFileName.txt'))
          .writeAsStringSync(entries.map((LogEntry entry) => entry.toString()).join('\n'));
      logger.fine('Screenshot and image saved to: ${normalizedDirname}');
    }
//    expect(entries.length, 0);
  });

  Logger.root.level = Level.ALL;
  logger.onRecord.listen(print);
  runTokenTest();
  runSlimViewTest();
}