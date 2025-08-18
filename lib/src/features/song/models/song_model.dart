class SongModel {
  final int id;
  final String songName;
  final String songFile;

  SongModel({required this.id, required this.songName, required this.songFile});

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? 0,
      songName: json['song_name'] ?? '',
      songFile: json['song_file'] ?? '',
    );
  }
}
