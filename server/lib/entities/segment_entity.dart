part of slim_vendor_app_server.entities;

class SegmentEntity extends JsonSerializable {
  final String source;
  final String key;
  final String page;

  String target;

  SegmentEntity(this.source, this.target, this.key, this.page);

  factory SegmentEntity.fromJson(Map json) {
    return new SegmentEntity(json['source'], json['target'], json['key'], json['page']);
  }

  Map toJson() {
    return {
      'source': source,
      'target': target,
      'key': key,
      'page': page
    };
  }
}

