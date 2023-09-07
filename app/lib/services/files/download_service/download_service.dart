import 'download_service_stub.dart'
if (dart.library.io) 'mobile_download_service.dart'
if (dart.library.html) 'web_download_service.dart';

abstract class DownloadService {
  static DownloadService? _instance;

  static DownloadService get instance {
    _instance ??= getManager();
    return _instance!;
  }

  Future<void> download({required String text, required String filename});

  Future<void> downloadFile({required String encodedContent, required String filename});
}
