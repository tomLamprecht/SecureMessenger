import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:my_flutter_test/services/files/download_service/download_service.dart';
import 'package:path_provider/path_provider.dart';

DownloadService getManager() =>
    MobileDownloadService();

class MobileDownloadService implements DownloadService{
  @override
  Future<void> download({required String text, required String filename}) async {
    final directory = await getApplicationSupportDirectory();
    log("Write cert file to ${directory.path}/$filename");
    final file = File('${directory.path}/$filename');
    await file.writeAsString(text, encoding: utf8);
  }
}
