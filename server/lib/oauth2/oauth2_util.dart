part of slim_vendor_app_server.oauth2;

class OAuth2Util {

  DocumentInfoEntity _documentInfo;

  /// OAuth2 endpoint base
  /// Can be configured in `app.yaml`
  @Value('oauthEndpoint')
  String oauthEndpoint;

  /// Can be configured in `app.yaml`
  @Value('oauthConsumerId')
  String consumerId;

  /// Can be configured in `app.yaml`
  @Value('oauthConsumerSecret')
  String consumerSecret;

  Future<String> getAuthorizationUrl() async {
    DocumentInfoEntity docInfo = await documentInfo;
    docInfo.authorizationEndpoint;
    Map<String, String> params = <String, String>{
      'client_id': consumerId,
      'response_type': 'code',
      'state': 'no-state-for-sample-code',
      'scope': 'slim-view',
      'redirect_uri': 'http://localhost:8080/oauth/desktopverify'
    };

    Uri authUri = Uri.parse(docInfo.authorizationEndpoint)
        .replace(queryParameters: params);
    return authUri.toString();
  }

  Future<http.Response> requestForToken(bool isAccessToken,
      {String code, String refreshToken}) async {
    Map<String, String> params = <String, String>{
      'client_id': consumerId,
      'client_secret': consumerSecret,
      'grant_type': isAccessToken ? 'authorization_code' : 'refresh_token',
      'redirect_uri': 'http://localhost:8080/oauth/desktopverify'
    };
    if (isAccessToken) {
      params['code'] = code;
    } else {
      params['refresh_token'] = refreshToken;
    }
    DocumentInfoEntity docInfo = await documentInfo;
    Uri accessTokenRequestUri = Uri.parse(docInfo.tokenEndpoint);
    return http.post(accessTokenRequestUri.toString(), body: params);
  }

  Future<Map> listProjects(String accessToken) {
    String endpoint = ApplicationContext.getValue('oauthEndpoint');
    return http.post('${endpoint}/projects',
        headers: {
          'Authorization': 'Bearer ${accessToken}'
        }
    ).then((http.Response projectsResponse) => JSON.decode(projectsResponse.body));
  }

  Future<DocumentInfoEntity> get documentInfo {
    if (_documentInfo != null)
      return new Future.value(_documentInfo);

    return http.get('$oauthEndpoint/document')
        .then((http.Response response) {
      _documentInfo = new DocumentInfoEntity.fromJson(JSON.decode(response.body));
      return _documentInfo;
    });
  }

  static String generateRandomString() {
    Random rand = new Random();
    List<int> codeUnits = new List.generate(16, (index) => (rand.nextInt(33) + 89));
    return new String.fromCharCodes(codeUnits);
  }

  Logger _logger = new Logger('OAuth2Util');
}