import 'dart:typed_data';

class AttachedFile {
  String? uuid;
  String fileName;
  String encodedFileContent;
  DateTime? createdAt;
  Uint8List? bytes;

  AttachedFile({
    this.uuid,
    required this.fileName,
    required this.encodedFileContent,
    this.createdAt,
    this.bytes
  });

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'fileName': fileName,
      'encodedFileContent': encodedFileContent,
      'createdAt': createdAt?.toIso8601String()
    };
  }

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
        uuid: json['uuid'],
        fileName: json['fileName'],
        encodedFileContent: json['encodedFileContent'],
        createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    String abbreviatedContent = "${encodedFileContent.substring(0, 25)}...";
    return "AttachedFile: { uuid: $uuid, fileName: $fileName, encodedFileContent: $abbreviatedContent, createdAt: $createdAt }";
  }
}