import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:glob/glob.dart';

Future<ByteData> _fetchFontFromCache() async {
  final String root = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  await for (FileSystemEntity path in Glob(
          'hosted/pub.dartlang.org/showcase-*/assets/Roboto/Roboto-Regular.ttf')
      .list(root: root)) {
    if (path is File) {
      final Uint8List bytes = Uint8List.fromList(await path.readAsBytes());
      return ByteData.view(bytes.buffer);
    }
  }
  throw Exception('Failed to load font');
}

Future<ByteData> _fetchFontFromInternet() async {
  final http.Response response = await http.get(
      'https://raw.githubusercontent.com/google/fonts/master/apache/roboto/Roboto-Regular.ttf');

  if (response.statusCode == 200) {
    return ByteData.view(response.bodyBytes.buffer);
  } else {
    throw Exception('Failed to load font');
  }
}

/// Fetch Roboto font from local cache, or from the internet, if it's not
/// found in the cache.
/// It needs to be done because flutter_test blocks access to package assets
/// (see https://github.com/flutter/flutter/issues/12999).
Future<ByteData> fetchFont() =>
    _fetchFontFromCache().catchError((_) => _fetchFontFromInternet());
