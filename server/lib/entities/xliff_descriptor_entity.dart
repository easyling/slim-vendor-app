part of slim_vendor_app_server.entities;


class XliffDescriptorEntity implements JsonSerializable {

  final String projectCode;
  final String sourceLocale;
  final String targetLocale;
  final List<SegmentEntity> segments;
  final bool segmented;
  final String exportFile;

  XliffDescriptorEntity(this.projectCode, this.sourceLocale, this.targetLocale, this.segments, this.segmented, this.exportFile);

  factory XliffDescriptorEntity.fromJson(Map json) {
    return new XliffDescriptorEntity(json['projectCode'],
        json['sourceLocale'],
        json['targetLocale'],
        (json['segments'] as Iterable)?.map((Map m) {
          return new SegmentEntity.fromJson(m);
        })?.toList(),
        json['segmented'],
        json['exportFile']);
  }

  Map toJson() {
    return {
      'projectCode': projectCode,
      'sourceLocale': sourceLocale,
      'targetLocale': targetLocale,
      'segmented': segmented,
      'exportFile': exportFile,
      'segments': segments
    };
  }
}



