import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/song/models/song_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SongViewmodel extends GetxController {
  var songData = <SongModel>[].obs;
  Map<String, String> headers = {'Authorization': dotenv.env['API_KEY'] ?? ''};

  @override
  void onInit() {
    fetchMusic();
    super.onInit();
  }

  Future<void> fetchMusic() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/music'),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body)['data'];
        songData.value = result
            .map<SongModel>((song) => SongModel.fromJson(song))
            .toList();
      }
    } catch (e) {
      print("fetchMusic error: $e");
    }
  }

  Future<void> uploadSongFile(File file, String songName) async {
    var tempId = DateTime.now().millisecondsSinceEpoch;
    songData.add(
      SongModel(
        id: tempId,
        songName: songName,
        songFile: file.path,
        mimetype: '',
      ),
    );

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['BASE_URL']}/music'),
    );
    request.headers.addAll(headers);

    ///mimetype
    String mimetype = 'audio/mpeg'; //default mp3
    String fileName = file.path.split('/').last.toLowerCase();
    if (fileName.endsWith('.mp3')) mimetype = 'audio/mpeg';
    if (fileName.endsWith('.wav')) mimetype = 'audio/wav';
    if (fileName.endsWith('.m4a')) mimetype = 'audio/mp4';
    if (fileName.endsWith('.flac')) mimetype = 'audio/flac';

    request.files.add(
      http.MultipartFile.fromBytes(
        'song_file',
        await file.readAsBytes(),
        filename: fileName,
        contentType: MediaType.parse(mimetype),
      ),
    );
    request.fields['song_name'] = songName;

    try {
      var response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var respStr = await http.Response.fromStream(response);
        var responseData = jsonDecode(respStr.body);
        var newSong = SongModel(
          id: responseData['id'],
          songName: songName,
          songFile: '${dotenv.env['BASE_URL']}/music/${responseData['id']}',
          mimetype: '',
        );
        final index = songData.indexWhere((s) => s.id == tempId);
        if (index != -1) songData[index] = newSong;
      } else {
        songData.removeWhere((s) => s.id == tempId);
      }
    } catch (_) {
      songData.removeWhere((s) => s.id == tempId);
    }
  }

  Future<void> editSong(int id, String songName, {String? filePath}) async {
    final index = songData.indexWhere((s) => s.id == id);
    if (index == -1) return;
    var oldSong = songData[index];
    songData[index] = SongModel(
      id: id,
      songName: songName,
      songFile: filePath != null
          ? '${dotenv.env['BASE_URL']}/music/$id'
          : oldSong.songFile,
      mimetype: '',
    );

    try {
      http.Response response;
      if (filePath != null) {
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${dotenv.env['BASE_URL']}/music/$id'),
        );
        request.headers.addAll(headers);
        request.fields['song_name'] = songName;

        ///mimetype
        String mimetype = 'audio/mpeg'; //default mp3
        String fileName = filePath.split('/').last.toLowerCase();
        if (fileName.endsWith('.mp3')) mimetype = 'audio/mpeg';
        if (fileName.endsWith('.wav')) mimetype = 'audio/wav';
        if (fileName.endsWith('.m4a')) mimetype = 'audio/mp4';
        if (fileName.endsWith('.flac')) mimetype = 'audio/flac';

        request.files.add(
          http.MultipartFile.fromBytes(
            'song_file',
            await File(filePath).readAsBytes(),
            filename: fileName,
            contentType: MediaType.parse(mimetype),
          ),
        );
        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.put(
          Uri.parse('${dotenv.env['BASE_URL']}/music/$id'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode({'song_name': songName}),
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        songData[index] = oldSong;
      }
    } catch (_) {
      songData[index] = oldSong;
    }
  }

  Future<void> deleteSong(int id) async {
    final index = songData.indexWhere((s) => s.id == id);
    if (index == -1) return;
    var removedSong = songData.removeAt(index);

    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/music/$id'),
        headers: headers,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        songData.insert(index, removedSong);
      }
    } catch (_) {
      songData.insert(index, removedSong);
    }
  }
}
