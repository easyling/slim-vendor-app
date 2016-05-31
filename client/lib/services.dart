@JS()
library slim_vendor_app_client.services;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:js/js.dart';
import 'package:angular2/core.dart' show Injectable, Provider;
import 'package:slim_vendor_app_server/entities.dart' show XliffDescriptorEntity;

part 'services/xliff_file_service.dart';
part 'services/authorization_js_provider.dart';