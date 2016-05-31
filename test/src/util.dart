/// Test utility functions and classes

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:webdriver/io.dart' hide createDriver;
import 'package:webdriver/support/async.dart';
import 'package:webdriver/src/command_processor.dart';

import 'abortable_test.dart' show abort;
import 'dart:collection';

Logger logger = new Logger('SlimTests Util');

Future forPageLoad(WebDriver driver, String url) {
  driver.get(url);
  return waitFor(() async {
    return await driver.execute('return document.readyState', []) == 'complete';
  });
}

Future screenShot(WebDriver driver, String filePath) async {
  // Block test execution until we wait
  List<int> codePoints = await driver.captureScreenshotAsList();
  File f = new File(filePath);
  RandomAccessFile io = f.openSync(mode: FileMode.WRITE);
  io
    ..writeFromSync(codePoints)
    ..flushSync()
    ..closeSync();
}

Future<bool> angularExecuted(WebDriver driver, {String loadMessage: 'Loading...'}) async {
  WebElement body = await driver.findElement(const By.tagName('body'));
  String value = await body.text;
  return value != loadMessage;
}

String generateFilename() {
  DateTime now = new DateTime.now();
  return '${now.year}-${now.month}-${now.day}_${now.hour}_${now.minute}_${now.second}';
}

class RuntimeBy extends By {
  RuntimeBy.name(String name) : super.name(name);

  RuntimeBy.id(String id) : super.id(id);

  RuntimeBy.className(String className) : super.className(className);

  RuntimeBy.tagName(String tagName) : super.tagName(tagName);

  RuntimeBy.cssSelector(String selector) : super.cssSelector(selector);
}

RuntimeBy byId(String id) => new RuntimeBy.id(id);

RuntimeBy byName(String cssSelector) => new RuntimeBy.name(cssSelector);

RuntimeBy byClassName(String cssSelector) => new RuntimeBy.className(cssSelector);

RuntimeBy byTagName(String cssSelector) => new RuntimeBy.tagName(cssSelector);

RuntimeBy bySelector(String cssSelector) => new RuntimeBy.cssSelector(cssSelector);

abstract class QuerySelector {
  SearchContext get searchTarget;

  Future<QueryWebElement> query(String selector) async {
    WebElement elem = await searchTarget.findElement(bySelector(selector));
    return new QueryWebElement(elem);
  }

  Stream<QueryWebElement> queryAll(String selector) {
    return searchTarget.findElements(bySelector(selector)).map((WebElement elem) => new QueryWebElement(elem));
  }
}


class QueryWebElement extends Object with QuerySelector implements WebElement {
  final WebElement baseElement;

  QueryWebElement(this.baseElement);

  @override
  Attributes get attributes => baseElement.attributes;

  @override
  Future clear() {
    return baseElement.click();
  }

  @override
  Future click() {
    return baseElement.click();
  }

  @override
  SearchContext get context => baseElement.context;

  @override
  Attributes get cssProperties => baseElement.cssProperties;

  @override
  Future<bool> get displayed => baseElement.displayed;

  @override
  WebDriver get driver => baseElement.driver;

  @override
  Future<bool> get enabled => baseElement.enabled;

  @override
  Future<bool> equals(WebElement other) {
    return baseElement.equals(other);
  }

  @override
  Future<WebElement> findElement(By by) {
    return baseElement.findElement(by);
  }

  @override
  Stream<WebElement> findElements(By by) {
    return baseElement.findElements(by);
  }

  @override
  String get id => baseElement.id;

  @override
  int get index => baseElement.index;

  @override
  Future<Point> get location => baseElement.location;

  @override
  get locator => baseElement.locator;

  @override
  Future<String> get name => baseElement.name;

  @override
  Future<bool> get selected => baseElement.selected;

  @override
  Future sendKeys(String keysToSend) {
    return baseElement.sendKeys(keysToSend);
  }

  @override
  Future<Rectangle<int>> get size => baseElement.size;

  @override
  Future submit() {
    return baseElement.submit();
  }

  @override
  Future<String> get text => baseElement.text;

  @override
  Map<String, String> toJson() {
    return baseElement.toJson();
  }

  @override
  SearchContext get searchTarget => baseElement;
}

class _QueryWebDriverBase extends WebDriver {
  _QueryWebDriverBase(CommandProcessor commandProcessor, Uri uri, String id, Map<String, dynamic> capabilities)
      : super(commandProcessor, uri, id, capabilities);
}

class QueryWebDriver extends _QueryWebDriverBase with QuerySelector {

  QueryWebDriver(CommandProcessor commandProcessor, Uri uri, String id, Map<String, dynamic> capabilities)
      : super(commandProcessor, uri, id, capabilities);

  @override
  Future<QueryWebElement> findElement(By by) async {
    WebElement elem = await super.findElement(by);
    return new QueryWebElement(elem);
  }

  @override
  Stream<QueryWebElement> findElements(By by) {
    return super.findElements(by).map((WebElement elem) => new QueryWebElement(elem));
  }

  @override
  SearchContext get searchTarget => this;

  @override
  Future postRequest(String command, [params]) {
    return super.postRequest(command, params)..catchError(_abort);
  }

  @override
  Future getRequest(String command) {
    return super.getRequest(command)..catchError(_abort);
  }

  @override
  Future deleteRequest(String command) {
    return super.deleteRequest(command)..catchError(_abort);
  }

  Future _abort(e) async {
    abort();
  }
}

Future<QueryWebDriver> createDriver({Uri uri, Map<String, dynamic> desired}) async {
  IOCommandProcessor processor = new IOCommandProcessor();
  if (uri == null) {
    uri = defaultUri;
  }

  if (desired == null) {
    desired = Capabilities.empty;
  }

  var response = await processor.post(
      uri.resolve('session'), {'desiredCapabilities': desired}, value: false);
  return new QueryWebDriver(processor, uri, response['sessionId'], new UnmodifiableMapView(response['value']));
}
