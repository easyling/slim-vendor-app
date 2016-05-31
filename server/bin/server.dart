library slim;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:logging/logging.dart';
import 'package:forcemvc/force_mvc.dart';
import 'package:wired/wired.dart';

import 'package:path/path.dart' as path;
import 'package:slim_vendor_app_server/xliff.dart' as xliff;
import 'package:slim_vendor_app_server/oauth2.dart';
import 'package:http/http.dart' as http;
import 'package:dirty/dirty.dart';

part 'controllers/project_controller.dart';

part 'controllers/oauth2_controller.dart';

part 'controllers/app_controller.dart';

/// Interface for DB operations
abstract class TokenStore {
  Future<bool> hasValidAccessToken();

  Future<String> getAccessToken();

  Future<String> getRefreshToken();

  void storeTokens(String accessToken, String refreshToken, int expiry);

  void clearAll();
}

class DirtyTokenStore implements TokenStore {

  /// Database in which tokens are to be stored
  final Dirty _db;
  Logger _logger = new Logger('DirtyTokenStore');

  DirtyTokenStore(this._db) {
    if (this._db == null)
      throw new ArgumentError.notNull('db');
  }

  @override
  Future<String> getAccessToken() {
    return new Future<String>.value(_db['access_token']);
  }

  @override
  Future<String> getRefreshToken() {
    return new Future<String>.value(_db['refresh_token']);
  }

  @override
  Future<bool> hasValidAccessToken() {
    return new Future<bool>.value(_db.containsKey('access_token')
        && new DateTime.now().isBefore(new DateTime.fromMillisecondsSinceEpoch(_db['token_expiry'])));
  }

  @override
  void storeTokens(String accessToken, String refreshToken, int expiry) {
    _db['access_token'] = accessToken;
    _db['refresh_token'] = refreshToken;
    _db['token_expiry'] = expiry;
  }

  @override
  void clearAll() {
    _db.clear();
  }
}

class SessionStrategy extends SecurityStrategy<HttpRequest> {

  @override
  bool checkAuthorization(HttpRequest req, List<String> roles, data) {
    return true;
  }

  @override
  Uri getRedirectUri(HttpRequest req) {
    return null;
  }
}

@Config
class AppConfig {

  @Bean
  OAuth2Util oauthUtil() {
    return new OAuth2Util();
  }

  @Bean
  TokenStore getDb() {
    Dirty db = new Dirty('${path.normalize(path.join(
        path.dirname(Platform.script.toFilePath(windows: Platform.isWindows)), 'db/db.db'))}');
    return new DirtyTokenStore(db);
  }
}

main() {
  print(path.dirname(Platform.script.toFilePath(windows: true)));

  WebApplication app = new WebApplication(clientFiles: '../../client/build/web',
      port: 8082);

  app.loadValues('../../app.yaml');
  ApplicationContext.bootstrap();
  app.setupConsoleLog(Level.FINEST);
  app.strategy = new SessionStrategy();
  app.start();
}
