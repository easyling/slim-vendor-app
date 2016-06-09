library slim_client;

import 'package:slim_vendor_app_client/slim_app.dart';
import 'package:angular2/platform/browser.dart';
import 'package:slim_vendor_app_client/components.dart';
import 'package:logging/logging.dart';
import 'package:slim_vendor_app_client/services.dart';

List<Type> getGlobalProviders() {
  return const [ SlimApp, slimViewChannelService ];
}


void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  bootstrap(AppComponent, getGlobalProviders());

  new SlimApp()
    ..start();
}
