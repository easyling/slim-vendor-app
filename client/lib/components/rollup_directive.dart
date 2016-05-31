part of slim_vendor_app_client.components;

@Directive(selector: '[rollup]')
class Rollup {

  @Input('rollup')
  Element rollupTarget;

  @Input('rollupCondition')
  void set rollupCondition(bool val) {
    toggleRollup(val);
  }

  @Output()
  EventEmitter<bool> onRollToggle = new EventEmitter<bool>();

  @HostListener('click')
  void toggleRollup([bool toState]) {
    rollupTarget.hidden = toState ?? !rollupTarget.hidden;
    onRollToggle.add(rollupTarget.hidden);
  }
}