part of slim_vendor_app_client.app;

@Injectable()
class SlimApp {

  XliffDescriptorEntity get selectedExport => _selectedExport;

  set selectedExport(XliffDescriptorEntity val) {
    _selectedExport = val;
    print(identityHashCode(this));
  }

  XliffDescriptorEntity _selectedExport;

  /// Do we have all the information on the selected xliff to
  /// start loading SlimView?
  bool get hasSelectedExport => selectedExport != null;

  SegmentEntity get selectedSegment => _selectedSegment;
  void set selectedSegment(val) {
    _selectedSegment = val;
    onSelectionChange.add(val);
  }
  SegmentEntity _selectedSegment;

  String _viewId;

  String getViewId() {
    _viewId ??= _generateViewId();
    return _viewId;
  }

  List<SegmentKey> entryKeyList;
  List<SegmentKey> tmKeyList;

  EventEmitter<SegmentEntity> onSelectionChange = new EventEmitter<SegmentEntity>();

  bool hasEntryKey(SegmentKey segmentKey) {
    return entryKeyList?.contains(segmentKey) || tmKeyList?.contains(segmentKey);
  }

  bool selectSegmentByKey(SegmentKey segmentKey) {
    if (hasSelectedExport && hasEntryKey(segmentKey)) {
      selectedSegment = selectedExport.segments
          .firstWhere((SegmentEntity segment) => segmentKey.equals(segment.key), orElse: () {
        return null;
      }
      );
    } else {
      resetSegmentSelection();
    }
    return selectedSegment != null;
  }

  void resetSegmentSelection() {
    selectedSegment = null;
  }

  String _generateViewId() {
    return 'abcdef';
  }

  void start() { }

}
