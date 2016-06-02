part of slim;

@Controller
@RequestMapping(value: '/oauth/')
class OAuth2Controller {

  @RequestMapping(value: 'start', method: RequestMethod.GET)
  Future<String> startAuth(ForceRequest req) async {
    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);
    String url = await util.getAuthorizationUrl(req.request.requestedUri);
    return 'redirect:$url';
  }

  @RequestMapping(value: 'verify', method: RequestMethod.GET)
  Future<String> verify(ForceRequest req, HttpSession session,
      @RequestParam(value: 'code', required: true) String code,
      @RequestParam(value: 'state', required: true) String state) async {
    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);
    http.Response tokenResponse = await util.requestForToken(true, req.request.requestedUri, code: code);
    Map response = JSON.decode(tokenResponse.body);
    Logger.root.finest("Response: ${tokenResponse.body}");
    storeTokens(response);
    return 'oauth_verified';
  }

  @RequestMapping(value: 'desktopverify', method: RequestMethod.GET)
  Future<String> desktopVerify(ForceRequest req, HttpSession session,
      @RequestParam(value: 'code', required: true) String code,
      @RequestParam(value: 'state', required: true) String state) async {
    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);
    http.Response tokenResponse = await util.requestForToken(true, req.request.requestedUri, code: code);
    Map response = JSON.decode(tokenResponse.body);
    Logger.root.finest("Response: ${tokenResponse.body}");
    storeTokens(response);
    return 'oauth_verified';
  }

  @RequestMapping(value: 'test', method: RequestMethod.GET)
  Future<Map> testActiveToken() async {
    TokenStore tokenStore = ApplicationContext.getBeanByType(TokenStore);
    if(await tokenStore.getAccessToken() == null) {
      return {
        'error': 'no_token_found',
        'error_description': 'User is not permitted to access project'
      };
    }
    if(!await tokenStore.hasValidAccessToken()) {
      return {
        'error': 'token_expired',
        'error_description': 'Token has expired'
      };
    }
    String token = await tokenStore.getAccessToken();
    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);
    return util.listProjects(token);
  }

  @RequestMapping(value: 'refresh', method: RequestMethod.GET)
  Future<Map> refreshToken(ForceRequest req) async {
    TokenStore tokenStore = ApplicationContext.getBeanByType(TokenStore);
    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);

    String refresh = await tokenStore.getRefreshToken();
    http.Response tokenResponse = await util.requestForToken(
        false, req.request.requestedUri, refreshToken: refresh);
    Map response = JSON.decode(tokenResponse.body);
    storeTokens(response, tokenStore);
    return response;
  }

  void storeTokens(Map response, [TokenStore tokenStore]) {
    if (tokenStore == null)
      tokenStore = ApplicationContext.getBeanByType(TokenStore);
    int expiry = new DateTime.now()
        .add(new Duration(seconds: response['expires_in']))
        .millisecondsSinceEpoch;
    tokenStore.storeTokens(response['access_token'], response['refresh_token'], expiry);
  }
}