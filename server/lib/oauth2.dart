library slim_vendor_app_server.oauth2;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:wired/wired.dart';
import 'dart:math';
import 'dart:convert';
import 'package:logging/logging.dart';

part 'oauth2/oauth2_util.dart';

class DocumentInfoEntity {

  final String issues;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final List<String> supportedScopes;
  final List<String> responseTypesSupported;
  final List<String> grantTypesSupported;

  Map _originalJson;

  DocumentInfoEntity._(this.issues, this.authorizationEndpoint, this.tokenEndpoint,
      this.supportedScopes, this.responseTypesSupported,
      this.grantTypesSupported);

  factory DocumentInfoEntity.fromJson(Map json) {
    return new DocumentInfoEntity._(
        json['issuer'],
        json['authorization_endpoint'],
        json['token_endpoint'],
        new List<String>.unmodifiable(json['scopes_supported']),
        new List<String>.unmodifiable(json['response_types_supported']),
        new List<String>.unmodifiable(json['response_types_supported']))
      .._originalJson = json;
  }

  Map toJson() => _originalJson;
}

// step 1: get document info
// step 2: authorize
// step 3:
