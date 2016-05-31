/// Utility function to process XLIFF files
library slim_vendor_app_server.xliff;

import 'dart:io';
import 'package:xml/xml.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import 'entities.dart';

XliffDescriptorEntity getXliffDescriptor(XmlDocument document, List<SegmentEntity> segments, bool segmented, String fileName) {
  XmlElement fileElement = document
      .findAllElements('file')
      .single;
  String projectCode = fileElement.getAttribute('original');
  String sourceLocale = fileElement.getAttribute('source-language');
  String targetLocale = fileElement.getAttribute('target-language');
  return new XliffDescriptorEntity(projectCode, sourceLocale, targetLocale, segments, segmented, fileName);
}

List<SegmentEntity> getSegments(XmlDocument document, bool segmented) {
  XmlElement bodyElement = document
      .findAllElements('body')
      .single;
  return bodyElement.findAllElements('trans-unit')
      .map((XmlElement element) {
    XmlElement source = element.children
        .firstWhere((XmlNode node) => node is XmlElement && node.name.local == 'source');
    XmlElement target = element.children
        .firstWhere((XmlNode node) => node is XmlElement && node.name.local == 'target',
        orElse: () => null);
    String sourceSerialized = source.children.map((XmlNode n) => n.toXmlString()).join();
    String targetSerialized = target?.children?.map((XmlNode n) => n.toXmlString())?.join();
    String href;
    if(!segmented) {
      href = element.getAttribute('xlink:href');
    } else {
      href = (element.parent as XmlElement).getAttribute('xlink:href');
    }
    return new SegmentEntity(sourceSerialized, targetSerialized, element.getAttribute('id'), href);
  }).toList();
}

Future<XliffDescriptorEntity> processXliff(String filePath) async {
  File f = new File(filePath);
  String contents = await f.readAsString();
  XmlDocument document = parse(contents);
  XmlElement bodyElement = document
      .findAllElements('body')
      .single;
  bool segmented = bodyElement.findElements('group').length > 0;;
  List<SegmentEntity> segments = getSegments(document, segmented);
  XliffDescriptorEntity descriptor = getXliffDescriptor(document, segments, segmented, path.basename(f.path));
  return descriptor;
}