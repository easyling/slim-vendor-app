part of slim_vendor_app.test;

Future<Iterable<QueryWebElement>> selectExport([int which]) async {
  return driver.query('xliff-list').then((QueryWebElement list) async {
    Iterable<QueryWebElement> labels = await list.queryAll('label').toList();
    await labels.elementAt(which ?? labels.length - 1).click();
    return labels;
  });
}

Future loginUsingEasylingMethod() async {
  QueryWebElement emailInput = await driver.query('#email');
  await emailInput.sendKeys('test@easyling.com');
  QueryWebElement passInput = await driver.query('#password');
  await passInput.sendKeys('sq8Tj9Bd');
  QueryWebElement loginBtn = await driver.query('#login');
  return loginBtn.click();
}

Future loginToLocalhost() async {
  QueryWebElement loginBtn = await driver.query('#btn-login');
  await loginBtn.click();
}

Future<bool> isLocalhost() {
  return driver.currentUrl.then((String url) => url.startsWith('http://localhost'));
}

void runTokenTest() {
  abortableGroup('Token ', () {
    setUpAll(() {
      // page has loaded
      expect(angularExecuted(driver), completion(true));
    });

    setUp(() {
      expect(shouldContinue(), true, reason: 'Previous test indicated that group execution should halt.');
    });

    Future<WebElement> getAuthorizationCard() async {
      return driver.query('#auth-status-card');
    }

    test('should list exports', () async {
      await forPageLoad(driver, vendorEndpoint.resolve('/?clear=1').toString());
      Iterable<QueryWebElement> labels = await selectExport();
      expect(labels.length, greaterThan(0));
    });

    test('authorization status shows up', () async {
      QueryWebElement authStatusCard = await getAuthorizationCard();
      String hasToken = await (await authStatusCard.query('.has-token')).text;
      expect(hasToken, endsWith('false'));
    });

    abortableGroup('Login and authorization', () {
      test('should be offered login method', () async {
        expect(driver.windows.toList(), completion(hasLength(1)));
        QueryWebElement authStatusCard = await driver.query('#new-token');
        authStatusCard.click();
        List<Window> windows = await driver.windows.toList();
        expect(windows, hasLength(2));
        await driver.switchTo.window(windows.last);
        expect(driver.currentUrl, completion(contains('?continue')));
      });

      test('can select login method', () async {
        QueryWebElement loginButton;
        if (await isLocalhost()){
          logger.info('Selecting Google login method');
          loginButton = await driver
              .queryAll('.federatedLoginMethod')
              .last;
        } else {
          logger.info('Selecting EL login method');
          loginButton = await driver
              .queryAll('.federatedLoginMethod')
              .first;
        }
        await loginButton.click();
      });

      test('can provide username and pass', () async {
        if(await isLocalhost()) {
          await loginToLocalhost();
        } else {
          await loginUsingEasylingMethod();
        }
      });

      test('can select projects to allow access to', () async {
        logger.info('Current url: ${await driver.currentUrl}');
        List<QueryWebElement> checkBoxes = await driver.queryAll('.skinnedCheck').toList();
        expect(checkBoxes, hasLength(greaterThan(1)));
        expect(checkBoxes.first.attributes['checked'], completion(isNotNull));

        QueryWebElement okBtn = await driver.query('button[value=confirm]');
        await okBtn.click();
      });

      test('should be redirected to vendor domain', () async {
        String currentUrl = await driver.currentUrl;
        Uri currentUri = Uri.parse(currentUrl);
        expect(currentUri.origin, equals(vendorEndpoint.origin));
      });

      test('can close window and finish process', () async {
        (await driver.query('button')).click();
        Iterable<Window> windows = await driver.windows.toList();
        expect(windows, hasLength(1));
        await driver.switchTo.window(windows.first);
      });
    });

    test('should have valid access token', () async {
      await forPageLoad(driver, vendorEndpoint.toString());
      await selectExport();
      QueryWebElement authStatusCard = await getAuthorizationCard();
      String hasValidToken = await (await authStatusCard.query('.token-validity')).text;
      expect(hasValidToken, endsWith('true'));
    });
  });
}