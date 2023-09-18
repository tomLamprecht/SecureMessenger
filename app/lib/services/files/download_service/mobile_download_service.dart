import 'dart:convert';
import 'dart:io';
import 'package:securemessenger/services/files/download_service/download_service.dart';
import 'package:path_provider/path_provider.dart';

DownloadService getManager() =>
    MobileDownloadService();

class MobileDownloadService implements DownloadService{
  @override
  Future<void> download({required String text, required String filename}) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(text, encoding: utf8);
  }

  @override
  Future<void> downloadFile({required String encodedContent, required String filename}) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$filename');
    final content = base64Decode(encodedContent);
    await file.writeAsBytes(content);
  }
}
