import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;
import 'package:glob/glob.dart';

Future<ByteData> _fetchFontFromFile(File file) async {
  final Uint8List bytes = Uint8List.fromList(await file.readAsBytes());
  return ByteData.view(bytes.buffer);
}

Future<ByteData> _fetchRobotoFromCache() async {
  final String root = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  await for (FileSystemEntity path in Glob(
          'hosted/pub.dartlang.org/showcase-*/assets/Roboto/Roboto-Regular.ttf')
      .list(root: root)) {
    if (path is File) {
      return _fetchFontFromFile(path);
    }
  }
  throw Exception('Failed to load font');
}

Future<ByteData> _fetchRobotoFromInternet() async {
  final http.Response response = await http.get(
      'https://raw.githubusercontent.com/google/fonts/master/apache/roboto/Roboto-Regular.ttf');

  if (response.statusCode == 200) {
    return ByteData.view(response.bodyBytes.buffer);
  } else {
    throw Exception('Failed to load font');
  }
}

Future<ByteData> _fetchRoboto() =>
    _fetchRobotoFromCache().catchError((_) => _fetchRobotoFromInternet());

Future<void> _loadRoboto() async {
  final FontLoader fontLoader = FontLoader('Roboto')..addFont(_fetchRoboto());
  await fontLoader.load();
}

/// Load all fonts found in pubspec.yaml, and fetch Roboto font from local
/// cache, or from the internet, if it's not found in the cache.
/// It needs to be done because flutter_test blocks access to package assets
/// (see https://github.com/flutter/flutter/issues/12999).
Future<void> loadFonts() async {
  await _loadRoboto();

  final dynamic yaml = loadYaml(await File('../pubspec.yaml').readAsString());
  if (yaml is YamlMap) {
    final dynamic fonts = yaml['flutter']['fonts'];
    if (fonts is YamlList) {
      for (final dynamic font in fonts.toList()) {
        if (font is YamlMap) {
          final FontLoader loader = FontLoader(font['family'].toString());
          for (YamlMap configuration in font['fonts']) {
            loader.addFont(
                _fetchFontFromFile(File('../${configuration['asset']}')));
          }
          await loader.load();
        }
      }
    }
  }
}
