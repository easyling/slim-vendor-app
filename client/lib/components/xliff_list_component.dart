part of slim_vendor_app_client.components;

@Component(selector: 'xliff-list',
    templateUrl: 'components/templates/xliff-list.html',
    styleUrls: const ['components/styles/xliff-list.css'],
    providers: const [xliffFileServiceProvider, authorizationInfoProvider],
    directives: const [XliffDetailComponent, Rollup])
class XliffListComponent {

  final XliffFileService fileService;
  final SlimApp app;
  final AuthorizationInfo authorizationInfo;

  XliffDescriptorEntity selectedExport;

  bool get hasSelectedFile => selectedExport != null;

  String endpointOrigin = 'http://localhost:8888';

  XliffListComponent(XliffFileService fileService, this.app, this.authorizationInfo)
      : fileService = fileService;

  void clearTokens() {
    window.location.href = '/clearTokens';
  }

  void getNewToken() {
    WindowBase authWindow = window.open('/oauth/start', 'Authorization');
    StreamSubscription<MessageEvent> sub;
    sub = window.onMessage.listen((MessageEvent ev) {
      if (ev.source.hashCode == authWindow.hashCode) {
        Map data = JSON.decode(ev.data);
        if (data['auth_success']) {
          sub.cancel();
          window.location.reload();
        } else {
          print('Auth failed... Should provide some feedback.');
        }
      } else {
        print('Message came from invalid auth source');
      }
    });
  }

  void openSlimView() {
    if (app.selectedSegment == null) {
      print('No file selection');
      return;
    }

    Map<String, String> parameters = <String, String>{
      'targetLanguage': app.selectedExport.targetLocale,
      'url': app.selectedSegment.page,
      'viewId': app.getViewId(),
      'o': emulateDesktop ? '1' : '2'
    };
    if (emulateDesktop) {
      parameters['em'] = '1';
    }

    Uri slimUri = Uri.parse(endpointOrigin)
        .resolve('/_sd/slim/${app.selectedExport.projectCode}') //
        .replace(queryParameters: parameters);

    WindowBase openedWindow = window.open(
        slimUri.toString(), 'Website Preview', 'height=800px,width=1000px,modal=yes,alwaysRaised=yes');
    print("${identityHashCode(openedWindow)}");
    if (emulateDesktop) {
      // emulation specific code - unrelated to channel
      window.onMessage.listen((MessageEvent ev) {
        if (ev.origin == slimUri.origin) {
          if (ev.data == 'emulation_started') {
            openedWindow.postMessage(JSON.encode({ 'command': 'setAccessToken', 'token': authorizationInfo.token}),
                slimUri.origin);
          }
        }
      });
      slimView.loadInNewWindow(app.getViewId(), openedWindow, slimUri.origin, ignoreToken: true);
    } else {
      slimView.loadInNewWindow(app.getViewId(), openedWindow, slimUri.origin);
    }
    slimView.slimViewChannel.registerCallback(slimView.SlimCommand.READY, (Map data) {
      app.entryKeyList = data['parameters']['keysFoundOnPage'].map((String k) => new SegmentKey(k)).toList();
      app.tmKeyList = data['parameters']['tmKeysFoundOnPage'].map((String k) => new SegmentKey(k)).toList();
      print(app.entryKeyList);
      print(app.tmKeyList);
      slimView.slimViewChannel.post(slimView.SlimCommand.VIEW, <String, dynamic>{
        "mode": "highlight"
      });
      sendSelectedEntryInfo();
    });
    slimView.slimViewChannel.registerCallback(slimView.SlimCommand.VIEW_CHANGED, (Map data) {
      if (!app.selectSegmentByKey(new SegmentKey(data['parameters']['highlightedEntryId']['uniqueKey'])))
        app.selectSegmentByKey(new SegmentKey(data['parameters']['highlightedEntryId']['nonUniqueKey']));
    });
    app.onSelectionChange.listen((_) {
      sendSelectedEntryInfo();
    });
  }

  void sendSelectedEntryInfo() {
    slimView.slimViewChannel.post(slimView.SlimCommand.VIEW, <String, dynamic>{
      "highlightedEntry": app.selectedSegment.key
    });
  }

  @HostListener('change', const ['\$event'])
  onSelectionChange(Event e) async {
    if (e.target is InputElement) {
      InputElement target = e.target;
      if (target.name == 'selectedFile') {
        String selectedFile = (e.target as InputElement).value;
        app.selectedExport = await fileService.getExportData(selectedFile);
        selectedExport = app.selectedExport;
      }
    }
  }


  toggleDesktopEmulation() {
    emulateDesktop = !emulateDesktop;
  }

  bool emulateDesktop = false;

  static const String slimBase = 'http://localhost:8888/_sd/slim/';
}
