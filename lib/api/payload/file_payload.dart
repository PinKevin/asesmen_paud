class FilePayload {
  final String filePath;

  FilePayload({
    required this.filePath,
  });

  factory FilePayload.fromJson(Map<String, dynamic> json) {
    return FilePayload(
      filePath: json['filePath'],
    );
  }
}
