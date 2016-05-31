/// This library is responsible for handling all the postMessage events on the vendor's side
/// All SlimView specific requests and commands
library slim_vendor;

import 'dart:html';
import 'dart:math' as math;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:js' as js;

final Logger _logger = new Logger('slim_vendor');

typedef void CommandCallback(Map data);

/// Channel is responsible for validating and maintaining a channel
/// through which bi-directional postMessage communication happens.
/// It is a singleton.
class Channel {

  final WindowBase slimWindow;
  final String slimViewOrigin;

  /// Only those commands will be accepted by the [Channel] that
  /// come from the appropriate targetWindow and has this id
  final String allowedViewId;

  Map<String, CommandCallback> handlerByCommand = {};

  /// Channel is ready to receive and send messages;
  bool get inited => _inited;
  bool _inited;

  Channel._(this.allowedViewId, this.slimWindow, this.slimViewOrigin) {
    _instance = this;
  }

  /// Constructor for singleton Channel - "There can only be one"
  factory Channel(String allowedViewId, WindowBase slimWindow, String slimViewOrigin) {
    return _instance ?? new Channel._(allowedViewId, slimWindow, slimViewOrigin);
  }

  void route(MessageEvent ev) {
    if(!eventOriginIsValid(ev.origin)) {
      _logger.info('Message from invalid origin:', ev.origin);
      return;
    }

    if (!eventSourceIsValid(ev)) {
      _logger.info('Message from invalid source:', ev.data);
      return;
    }

    Map message;
    try {
      message = JSON.decode(ev.data);
    } catch (e) {
      _logger.info('Invalid message', ev.data);
      return;
    }

    if (!viewIdIsValid(message)) {
      return;
    }

    callRegisteredHandler(message);
  }

  bool eventOriginIsValid(String origin) {
    return origin == slimViewOrigin;
  }

  void callRegisteredHandler(Map message) {
    String command = message['command'];
    _logger.fine('Routing message: ${message}');
    if (handlerByCommand.containsKey(command)) {
      handlerByCommand[command](message);
    } else {
      _logger.warning('Could not find handler command for ${command}.');
    }
  }

  void registerCallback(String command, CommandCallback callback) {
    if (!SlimCommand.VALID_COMMANDS.contains(command)) {
      _logger.warning('Invalid command `${command}`. Allowed commands: ${SlimCommand.VALID_COMMANDS}');
      return;
    }
    switch (command) {
      case SlimCommand.LOADED:
        handlerByCommand[command] = _wrapLoadedCallback(callback);
        break;
      case SlimCommand.READY:
        handlerByCommand[command] = _wrapReadyCallback(callback);
        break;
      default:
        handlerByCommand[command] = callback;
        break;
    }
  }

  /// Send a postMessage message to the window with which this [channel] can communicate with
  void post(String command, Map data) {
    _sendRequest(command, data);
  }

  CommandCallback _wrapLoadedCallback(CommandCallback callback) {
    return (Map data) {
      _sendResponse('vendorReady', {
        'accessToken': js.context['authorization']['token']
      });
      if(callback != null)
        callback(data);
    };
  }

  CommandCallback _wrapReadyCallback(CommandCallback callback) {
    return (Map data) {
      _inited = true;
      if(callback != null)
        callback(data);
    };
  }

  void _sendResponse(String command, Map data) {
    _logger.fine('Responding with: ${command}');
    slimWindow.postMessage(JSON.encode({
      'command': command,
      'viewId': allowedViewId,
      'response': data
    }), '*');
  }

  void _sendRequest(String command, Map data) {
    _logger.fine('Requesting: ${command}');
    int rnd = new math.Random().nextInt(89999) + 10000;
    slimWindow.postMessage(JSON.encode({
      'command': command,
      'viewId': allowedViewId,
      'messageId': rnd.toString(),
      'parameters': data
    }), '*');
  }


  bool eventSourceIsValid(MessageEvent ev) {
    // identical and operator== returns false as the Dart wrapped DOM object WILL differ.
    // However hashCodes do match as they return the hashCode of the JSObject
    return ev.source.hashCode == slimWindow.hashCode;
  }

  bool viewIdIsValid(Map message) {
    return message.containsKey('viewId') ? message['viewId'] == allowedViewId : false;
  }

  static Channel _instance;
}

Channel slimViewChannel;
bool get _channelIsRunning => slimViewChannel != null;

void loadInNewWindow(String allowedViewId, WindowBase baseWindow, String slimViewOrigin) {
  if(_channelIsRunning)
    return;
  _logger.info('Starting SlimView Vendor channel for [${slimViewOrigin}] and [${allowedViewId}]');
  _startChannel(allowedViewId, baseWindow, slimViewOrigin);
  _registerHandshakeDefaults();
}

void _startChannel(String allowedViewId, WindowBase baseWindow, String slimViewOrigin) {
  slimViewChannel = new Channel(allowedViewId, baseWindow, slimViewOrigin);
  window.onMessage.listen(slimViewChannel.route);
}

void _registerHandshakeDefaults() {
  slimViewChannel.registerCallback(SlimCommand.LOADED, null);
  slimViewChannel.registerCallback(SlimCommand.READY, null);
}

// 1: slimViewLoaded | viewId

class SlimCommand {
  static const String LOADED = 'slimViewLoaded';
  static const String READY = 'slimViewReady';
  static const String VIEW_CHANGED = 'viewChanged';
  static const String VIEW = 'view';
  static const String INVALID_ACCESS_TOKEN = 'invalidAccessToken';

  static const List<String> VALID_COMMANDS = const [ LOADED, READY, VIEW_CHANGED, INVALID_ACCESS_TOKEN];
}