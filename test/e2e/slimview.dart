part of slim_vendor_app.test;

Future<QueryWebElement> get hvFrame async {
  QueryWebElement hvFrame = await driver.query('#embedHighlightView');
  return hvFrame;
}

void runSlimViewTest() {
  abortableGroup('SlimView ', () {
    Future<QueryWebElement> getEntryList() {
      return driver.query('entry-list');
    }

    Future<QueryWebElement> getOpenButton() {
      return driver.query('#open-slim-btn');
    }

    setUpAll(() async {
      String currentUrl = await driver.currentUrl;
      if(!currentUrl.contains(vendorEndpoint.toString())) {
        await forPageLoad(driver, vendorEndpoint.toString());
        await selectExport();
      }
    });

    test('can select entry', () async {
      QueryWebElement entryList = await getEntryList();
      QueryWebElement firstEntry = await entryList.query('li');
      await (firstEntry).click();
      expect(firstEntry.attributes['class'], completion(contains('selected')));
    });

    test('can open', () async {
      QueryWebElement openButton = await getOpenButton();
      expect(openButton.attributes['disabled'], completion(isNot(isTrue)));
    });

    test('opens in new window', () async {
      QueryWebElement openButton = await getOpenButton();
      await openButton.click();
      List<Window> windows = await driver.windows.toList();
      expect(windows, hasLength(greaterThan(1)));
      await driver.switchTo.window(windows.last);
      await new Clock().sleep(new Duration(seconds: 10));
    });

    test('preview shows up', () async {
      // we are still on SlimView
      QueryWebElement preview = await hvFrame;
      expect(preview, isNotNull);
      String src = await preview.attributes['src'];
      expect(src, allOf(isNotNull, isNotEmpty, isNot('about:blank')));
    });

    test('preview loads', () async {
      QueryWebElement preview = await hvFrame;
      await driver.switchTo.frame(preview);
      await waitFor(() async {
        return await driver.execute('return document.readyState', []) == 'complete';
      });
    });
  });
}