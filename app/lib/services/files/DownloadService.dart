import 'dart:convert';

import 'package:universal_html/html.dart' as html;

abstract class DownloadService {
  Future<void> download({required String text, required String filename});
}

class WebDownloadService implements DownloadService {
  @override
  Future<void> download({required String text, required String filename}) async {
    // prepare
    final bytes = utf8.encode(text);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

class MobileDownloadService implements DownloadService {
  @override
  Future<void> download({required String text, required String filename}) {
    throw UnimplementedError();
  }
}
