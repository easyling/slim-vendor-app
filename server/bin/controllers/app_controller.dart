part of slim;

@Controller
class AppController {

  @RequestMapping(value: '/', method: RequestMethod.GET)
  Future<String> index(@RequestParam(value: 'clear', defaultValue: '0') String clearTokens, Model model) async {
    if(clearTokens != '0') {
      DirtyTokenStore store = ApplicationContext.getBeanByType(DirtyTokenStore);
      store.clearAll();
    }

    OAuth2Util util = ApplicationContext.getBeanByType(OAuth2Util);
    Uri endpoint = Uri.parse(util.oauthEndpoint).replace(path: '/_sd/slim');
    model.addAttribute('xliffFiles', JSON.encode(xliffFiles));
    model.addAttribute('authorization', JSON.encode(await getAuthorizationStatus()));
    model.addAttribute('slimEndpoint', JSON.encode(endpoint.toString()));
    return 'index';
  }

  @RequestMapping(value: '/clearTokens', method: RequestMethod.GET)
  String clearAllTokens() {
    TokenStore store = ApplicationContext.getBeanByType(TokenStore);
    store.clearAll();
    return 'redirect:/';
  }

  Future<Map<String, String>> getAuthorizationStatus() async {
    TokenStore store = ApplicationContext.getBeanByType(TokenStore);
    return {
      'hasValidToken': await store.hasValidAccessToken(),
      'token': await store.getAccessToken() ?? ''
    };
  }

  List<String> get xliffFiles {
    Directory xliffDir = new Directory(xliffPath);
    return xliffDir.listSync(followLinks: false)
        .where((FileSystemEntity entity) => FileSystemEntity.isFileSync(entity.path))
        .map((FileSystemEntity entity) => p.basename(entity.path))
        .toList();
  }

  String get xliffPath => p.absolute(
      p.normalize('./${ApplicationContext.getValue('xliffPath')}'));
}