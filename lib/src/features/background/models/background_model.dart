class BackgroundModel {
  final int id;
  final String filename;
  final String mimetype;

  BackgroundModel({
    required this.id,
    required this.filename,
    required this.mimetype,
  });

  factory BackgroundModel.fromJson(Map<String, dynamic> json) {
    return BackgroundModel(
      id: json['id'] ?? 0,
      filename: json['filename'] ?? '',
      mimetype: json['mimetype'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'filename': filename, 'mimetype': mimetype};
  }
}
