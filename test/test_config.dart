import 'dart:io';

//final Uri easylingEndpoint = Uri.parse('http://localhost:8888');
final Uri vendorEndpoint = Uri.parse(Platform.environment['VENDOR_ENDPOINT']?.trim() ?? 'http://localhost:8082');
