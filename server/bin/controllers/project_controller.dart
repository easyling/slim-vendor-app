part of slim;

@Controller
@RequestMapping(value: '/api/export/')
class ProjectController {

  @RequestMapping(value: "list/{file}", method: RequestMethod.GET)
  Future<Map> getXliffList(ForceRequest req, String file) {
    xliff.processXliff(path.join(xliffPath, file))
        .then(req.async);
    return req.asyncFuture;
  }

  String get xliffPath => path.absolute(
      path.normalize('./${ApplicationContext.getValue('xliffPath')}'));
}