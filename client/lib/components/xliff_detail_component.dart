part of slim_vendor_app_client.components;

@Component(
    selector: 'xliff-detail',
    templateUrl: 'components/templates/xliff-detail.html'
)
class XliffDetailComponent {
  @Input()
  XliffDescriptorEntity export;

  final SlimApp app;

  XliffDetailComponent(this.app);
}