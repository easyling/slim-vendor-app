@JS()
library slim_vendor_app_client.components;

import 'package:angular2/core.dart';
import 'package:slim_vendor_app_client/services.dart';
import 'package:slim_vendor_app_client/slim_app.dart';
import 'package:slim_vendor_app_server/entities.dart' show XliffDescriptorEntity, SegmentEntity;
import 'package:dart_slimlib/dart_slimlib.dart' as SlimView;
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'package:js/js.dart';


part 'directives/rollup_directive.dart';

part 'components/app/app_component.dart';
part 'components/xliff-list/xliff_list_component.dart';
part 'components/xliff-detail/xliff_detail_component.dart';
part 'components/entry-list/entry_list_component.dart';