part of slim_vendor_app_client.services;

@JS('authorization.hasValidToken')
external bool get _hasValidToken;

@JS('authorization.token')
external String get _token;

class AuthorizationInfo {
  final bool hasValidToken;
  final String token;

  bool get hasAccessToken => token?.isNotEmpty;

  bool get tokenIsValid => hasValidToken;

  bool get tokenHasExpired => hasAccessToken && !tokenIsValid;

  AuthorizationInfo._(this.hasValidToken, this.token);

  factory AuthorizationInfo() {
    return new AuthorizationInfo._(_hasValidToken, _token);
  }
}

@Injectable()
AuthorizationInfo authorizationInfoFactory() => new AuthorizationInfo();

const Provider authorizationInfoProvider = const Provider(AuthorizationInfo, useFactory: authorizationInfoFactory);