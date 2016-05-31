# Slim Vendor Tests

Tests are aimed to validate the integration and appropriate working of SlimView in a 3rd party application.

## Setting up for testing

There are some runtime requirements to running the test.

- Have dart runtime environment: [Dart website](https://www.dartlang.org/downloads/)
- Selenium standalon server: [Selenium server download](http://www.seleniumhq.org/download/)
- Drivers:
  - Chrome driver: [Download chrome driver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
  - Firefix has built in driver, no further downloads required

## Running the Test Application

- Configure endpoints and consumer information in: `server/app.yaml`
- Run the test server: `run.sh` or `run.bat`

It is a prerequisite of the enviroment to have dart installed. [Dart website](https://www.dartlang.org/downloads/)

## Running tests

Tests assume that Selenium server is listening on port `4444` and hub path is `wd/hub`.
These are the default settings of selenium server.
```
pub get #updates package dependencies
pub run test test/slim_test.dart -r compact -p vm
```

### CI Integration

For integration with a CI, `json` test report output can be transformed. There is a dependency:
```
pub global activate junitreport
```
Running test will be a bit different:

``` bash
pub run test test/slim_test.dart -r json -p vm > /tmp/test_results.json
pub global run junitreport:tojunit --input /tmp/test_results.json
```

This will print the JUnit XML to the STDOUT. By providing `--output` option the junitreport,
the output can be piped into a file.

## Optional IDE setup

Attaching `protractor` and `jasmine` to the project helps with code validation and highlighting.

In Webstorm that can be achieved by `File -> Settings -> Javascript -> Libraries -> Download`.
You will be looking for `angularjs-protractor`, `jasmine`, `selenium-webdriver` packages.

## Test file locations

All end-to-end tests are located in the `e2e` folders.