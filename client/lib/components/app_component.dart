part of slim_vendor_app_client.components;

@Component(selector: 'slim-app',
    templateUrl: 'components/templates/app.html',
    directives: const [ XliffListComponent, EntryListComponent])
class AppComponent {
  AppComponent();
}