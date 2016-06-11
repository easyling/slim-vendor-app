part of slim_vendor_app_client.components;

@Component(
    selector: 'entry-list',
    templateUrl: 'components/entry-list/entry-list.html',
    styleUrls: const ['components/entry-list/entry-list.css']
)
class EntryListComponent {

  @Input()
  XliffDescriptorEntity xliff;

  final SlimApp app;

  final SlimViewChannelService channelService;

  EntryListComponent(this.app, this.channelService);

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


  void change(Event ev) {
    if (_bounceTimer != null) {
      _bounceTimer.cancel();
      _bounceTimer = null;
    }
    String targetValue = (ev.target as Node).text?.trim();
    _bounceTimer = new Timer(new Duration(milliseconds: 250), () {
      print("Subbmitting: ${targetValue}");
      channelService.channel.translate(app.selectedSegment.key, targetValue, false);
    });
  }

  Timer _bounceTimer;
}

