import 'dart:io';

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:slim_vendor_app_server/entities.dart';
import 'package:slim_vendor_app_server/xliff.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

const String testFile = './test/static/localhost-unsegmented-skawa.hu_en-US_gmwcfpsx.xlf';
//const String testFile = './test/static/localhost-segmented-skawa.hu_en-US_gmwcfpsx.xlf';

main() async {
  XmlElement fileElement;
  XmlElement bodyElement;
  XmlDocument document;
  bool segmented;

  setUpAll(() async {
    File f = new File(testFile);
    String contents = await f.readAsString();
    document = parse(contents);
    fileElement = document
        .findAllElements('file')
        .single;
    bodyElement = document
        .findAllElements('body')
        .single;
    segmented = bodyElement
        .findElements('group')
        .length > 0;
    ;
  });
  test('Tests are ready to go', () {
    expect(fileElement, isNotNull);
    expect(bodyElement, isNotNull);
  });
  group('SegmentEntity', () {
    SegmentEntity segment;
    setUpAll(() {
      segment = new SegmentEntity('source', 'target', 'key', 'page');
    });
    test('property assignments OK', () {
      expect(segment.source, 'source');
      expect(segment.target, 'target');
      expect(segment.key, 'key');
    });
    test('JSON encode/decode', () {
      SegmentEntity decoded = new SegmentEntity.fromJson(JSON.decode(JSON.encode(segment)));
      expect(segment.key, decoded.key);
      expect(segment.source, decoded.source);
      expect(segment.target, decoded.target);
    });
    test('getSegments populates SegmentEntities properly', () {
      List<SegmentEntity> segments;
      expect(() {
        segments = getSegments(document, segmented);
      }, returnsNormally);
      expect(segments.length, greaterThan(0));
      SegmentEntity firstEntity = segments.first;
      expect(firstEntity.key, startsWith('gmwcfpsx_tm:WzeObnq7ZxkXqqVAHSRSBOTqTXJipukZB7pgefkzlck=zQqphWFHtsW0/yt9/uXaIKo4JTCZ7xtKZKztIzya/ik='));
      expect(firstEntity.source, '<g id="_0">3. helyezett: Budapest Bank startup verseny (2010)</g>');
      expect(firstEntity.target, '<g id="_0" xml:space="default">3rd place: </g>');
      expect(firstEntity.page, 'http://skawa.hu/cegunkrol');
    });
  });

  group('XliffDescriptor', () {
    test('getXliffDescriptor properties check out', () {
      XliffDescriptorEntity entity = getXliffDescriptor(document, null, segmented, path.basename(testFile));
      expect(entity.projectCode, equalsIgnoringCase('gmwcfpsx'));
      expect(entity.targetLocale, equalsIgnoringCase('en-US'));
      expect(entity.sourceLocale, equalsIgnoringCase('hu-HU'));
      expect(entity.segmented, segmented);
      expect(entity.exportFile, path.basename(testFile));
    });
    test('getXliffDescriptor JSON serializable/deserialize', () {
      XliffDescriptorEntity entity = getXliffDescriptor(document, null, segmented, path.basename(testFile));
      XliffDescriptorEntity decoded;
      expect(() {
        decoded = new XliffDescriptorEntity.fromJson(JSON.decode(JSON.encode(entity)));
      }, returnsNormally);
      expect(decoded.projectCode, entity.projectCode);
      expect(decoded.sourceLocale, entity.sourceLocale);
      expect(decoded.targetLocale, entity.targetLocale);
      expect(entity.segmented, entity.segmented);
    });
  });

  group('processXliff', () {
    test('returns with valid descriptor', () async {
      XliffDescriptorEntity descriptor = await processXliff(testFile);;
      expect(descriptor, isNotNull);
      expect(descriptor.segmented, segmented);
    });
  });
}