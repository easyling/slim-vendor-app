/// Wrapper for handler segment keys. Keys are treated equal regardless of
/// segmentation.

part of slim_vendor_app_client.app;

class SegmentKey {

  final String _key;

  SegmentKey(this._key);

  @override
  bool operator ==(SegmentKey other) {
    if (identical(this, other))
      return true;
    return _transform(_key) == _transform(other._key);
  }

  @override
  int get hashCode => _key.hashCode * 17;

  @override
  String toString() => _transform(_key);

  bool equals(String key) {
    if (key == null)
      return false;
    return new SegmentKey(key) == this;
  }

  static String _transform(String key) {
    // remove segmentation info from keys
    if (key.contains(SEGMENTED_KEY_REGEX)) {
      int lastHashtag = key.lastIndexOf('#');
      return key.substring(0, lastHashtag);
    }
    return key;
  }

  static RegExp SEGMENTED_KEY_REGEX = new RegExp(r'#[0-9]+$');
}
