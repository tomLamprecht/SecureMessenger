import 'dart:convert';
import 'dart:math';

import 'package:universal_html/html.dart' as html;

import 'package:securemessenger/services/files/download_service/download_service.dart';
import 'package:mime/mime.dart';

DownloadService getManager() =>
    WebDownloadService();

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

  @override
  Future<void> downloadFile({required String encodedContent, required String filename}) async {
    // prepare
    final bytes = base64Decode(encodedContent);
    String? mimeType = lookupMimeType(filename);

    if (mimeType == null) {
      List<int> headerBytes = bytes.sublist(0, min(4096, bytes.length));
      mimeType = lookupMimeType('', headerBytes: headerBytes);
    }

    final blob = html.Blob([bytes], mimeType);
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
