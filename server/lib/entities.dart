/// Collection of Plain on Dart objects that are shared between the Client and Server
library slim_vendor_app_server.entities;

part 'entities/segment_entity.dart';
part 'entities/xliff_descriptor_entity.dart';

abstract class JsonSerializable {
  Map toJson();
}