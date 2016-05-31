part of slim_vendor_app_client.services;

/// These values come from JavaScript context
@JS('xliffFiles')
external List<String> get _jsFiles;

/// Backend service to communicate with `/api/export` endpoints
///
/// As a dependency, [xliffFileServiceProvider] should be used
class XliffFileService {

  final List<String> files;

  Future<XliffDescriptorEntity> getExportData(String export) {
    return HttpRequest.getString('/api/export/list/$export').then((String val) {
      Map jsonMap = JSON.decode(val);
      XliffDescriptorEntity descriptor = new XliffDescriptorEntity.fromJson(jsonMap);
      return descriptor;
    });
  }

  XliffFileService(this.files);
}

@Injectable()
xliffFileServiceFactory() => new XliffFileService(_jsFiles);

const Provider xliffFileServiceProvider = const Provider(XliffFileService, useFactory: xliffFileServiceFactory);