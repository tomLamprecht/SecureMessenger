import 'dart:developer';

import 'download_service.dart';

DownloadService getManager() =>
    throw UnsupportedError('Cannot create an auth manager');

class DownloadServiceStub implements DownloadService {
  @override
  Future<void> download({required String text, required String filename}) async {
    log("Error because stub was activated");
    throw UnimplementedError();
  }

  @override
  Future<void> downloadFile({required String encodedContent, required String filename}) {
    log("Error because stub was activated");
    throw UnimplementedError();
  }
}
