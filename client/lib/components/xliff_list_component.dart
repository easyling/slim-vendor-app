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
  final SlimViewChannelService channelService;

  XliffDescriptorEntity selectedExport;

  bool get hasSelectedFile => selectedExport != null;

  String endpointOrigin = 'http://localhost:8888';

  XliffListComponent(XliffFileService fileService, this.app, this.authorizationInfo, this.channelService)
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

    channelService.config = new SlimView.Config()
      ..endpoint = endpointOrigin
      ..previewPage = app.selectedSegment.page
      ..targetLanguage = app.selectedExport.targetLocale
      ..projectCode = app.selectedExport.projectCode
      ..token = emulateDesktop ? null : authorizationInfo.token;
    if (emulateDesktop) {
      channelService.config.extra = SlimView.box(<String, String>{ 'em' : '1', 'o': '1'});
    }


    channelService.channel = new SlimView.Channel(channelService.config)
      ..onError(SlimView.allowInterop((msg) {
        Map message = SlimView.unboxMessage(msg);
        if (message['command'] == 'invalidAccessToken') {
          print('invalid token');
        }
      }))
      ..onMessage(SlimView.allowInterop((msg) {
        Map message = SlimView.unboxMessage(msg);
        print("Message: ${message}");
        switch (message['command']) {
          case 'slimViewReady':
            app.entryKeyList = message['parameters']['keysFoundOnPage'].map((String k) => new SegmentKey(k)).toList();
            app.tmKeyList = message['parameters']['tmKeysFoundOnPage'].map((String k) => new SegmentKey(k)).toList();
            channelService.channel.enableHighlighting();
            sendSelectedEntryInfo(channelService.channel);
            break;
          case 'viewChanged':
            if (!app.selectSegmentByKey(new SegmentKey(message['parameters']['highlightedEntryId']['uniqueKey'])))
              app.selectSegmentByKey(new SegmentKey(message['parameters']['highlightedEntryId']['nonUniqueKey']));
            break;
        }
      }));

    if (emulateDesktop) {
      // emulation specific code - unrelated to channel
      window.onMessage.listen((MessageEvent ev) {
        if (ev.origin == slimUri.origin) {
          if (ev.data == 'emulation_started') {
            new JsObject.fromBrowserObject(channelService.channel.window)
                .callMethod(
                'postMessage', [
              JSON.encode({ 'command': 'setAccessToken', 'token': authorizationInfo.token}),
              slimUri.origin
            ]);
          }
        }
      });
      channelService.channel.openInNewWindow();
    } else {
      channelService.channel.openInNewWindow();
    }
    app.onSelectionChange.listen((_) {
      sendSelectedEntryInfo(channelService.channel);
    });
  }

  void sendSelectedEntryInfo(SlimView.Channel channel) {
    channel.highlight(app.selectedSegment.key);
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
