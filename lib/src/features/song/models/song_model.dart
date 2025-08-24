class SongModel {
  final int id;
  final String songName;
  final String songFile;
  final String mimetype;

  SongModel({
    required this.id,
    required this.songName,
    required this.songFile,
    required this.mimetype,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? 0,
      songName: json['song_name'] ?? '',
      songFile: json['song_file'] ?? '',
      mimetype: json['mimetype'] ?? '',
    );
  }
}
