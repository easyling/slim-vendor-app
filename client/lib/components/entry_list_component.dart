part of slim_vendor_app_client.components;

@Component(
    selector: 'entry-list',
    templateUrl: 'components/templates/entry-list.html',
    styleUrls: const ['components/styles/entry-list.css']
)
class EntryListComponent {

  @Input()
  XliffDescriptorEntity xliff;

  final SlimApp app;

  EntryListComponent(this.app);

  bool presentInPreview(SegmentEntity segment) {
    return app.hasEntryKey(new SegmentKey(segment.key));
  }

  bool missingInPreview(SegmentEntity segment) {
    return app.entryKeyList != null && !app.hasEntryKey(new SegmentKey(segment.key));
  }

  String getTitleFor(SegmentEntity segment) {
    if (app.entryKeyList == null)
      return '';
    return app.hasEntryKey(new SegmentKey(segment.key))
        ? 'Segment is present in Preview'
        : 'Segment is not found in Preview';
  }

  void selectSegment(SegmentEntity segment) {
    app.selectedSegment = segment;
  }

  bool isSelected(SegmentEntity segment) {
    if (app.selectedSegment == null) {
      return false;
    }
    return new SegmentKey(segment.key).equals(app.selectedSegment.key);
  }

  void blur() {
    // TODO: send
  }
}

