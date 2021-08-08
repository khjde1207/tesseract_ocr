// part of flutter_tesseract_ocr;
import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'models/models.dart';

class FlutterTesseractOcr {
  static const String TESS_DATA_CONFIG = 'assets/tessdata_config.json';
  static const String TESS_DATA_PATH = 'assets/tessdata';
  static const MethodChannel _channel =
      const MethodChannel('flutter_tesseract_ocr');

  /// image to  text
  ///```
  /// String _ocrText = await FlutterTesseractOcr.extractText(url, language: langs, args: {
  ///    "preserve_interword_spaces": "1",});
  ///```
  static Future<String> extractText(String imagePath,
      {String? language, Map? args}) async {
    assert(await IO.File(imagePath).exists(), true);
    final String tessData = await _loadTessData();
    final String extractText =
        await _channel.invokeMethod('extractText', <String, dynamic>{
      'imagePath': imagePath,
      'tessData': tessData,
      'language': language,
      'args': args,
    });
    return extractText;
  }

  static Future<bool> initTesseract({String? language, Map? args}) async {
    final String tessData = await _loadTessData();
    final bool status =
        await _channel.invokeMethod('initswiftyTesseract', <String, dynamic>{
      'tessData': tessData,
      'language': language,
      'args': args,
    });
    return status;
  }

  static Future<String> extractTextLive(Uint8List image) async {
    final String tessData = await _loadTessData();
    final extractText =
        await _channel.invokeMethod('extractTextLive', <String, dynamic>{
      'imageData': image,
    });
    return extractText;
  }

  /// image to  html text(hocr)
  ///```
  /// String _ocrHocr = await FlutterTesseractOcr.extractText(url, language: langs, args: {
  ///    "preserve_interword_spaces": "1",});
  ///```
  static Future<String> extractHocr(String imagePath,
      {String? language, Map? args}) async {
    assert(await IO.File(imagePath).exists(), true);
    final String tessData = await _loadTessData();
    final String extractText =
        await _channel.invokeMethod('extractHocr', <String, dynamic>{
      'imagePath': imagePath,
      'tessData': tessData,
      'language': language,
      'args': args,
    });
    return extractText;
  }

  /// getTessdataPath
  ///```
  /// print(await FlutterTesseractOcr.getTessdataPath())
  ///```
  static Future<String> getTessdataPath() async {
    final IO.Directory appDirectory = await getApplicationDocumentsDirectory();
    final String tessdataDirectory = join(appDirectory.path, 'tessdata');
    return tessdataDirectory;
  }

  static Future<String> _loadTessData() async {
    final IO.Directory appDirectory = await getApplicationDocumentsDirectory();
    final String tessdataDirectory = join(appDirectory.path, 'tessdata');

    // var oi = appDirectory.list();
    // oi.forEach((element) {
    //   print(element);
    // });

    // print("tessdataDirectiry to Path" + tessdataDirectory);

    if (!await IO.Directory(tessdataDirectory).exists()) {
      await IO.Directory(tessdataDirectory).create();
      // print(tessdataDirectory + " -> Created");
    }
    await _copyTessDataToAppDocumentsDirectory(tessdataDirectory);
    // print("Path rturned");
    return appDirectory.path;
  }

  static Future _copyTessDataToAppDocumentsDirectory(
      String tessdataDirectory) async {
    final String config = await rootBundle.loadString(TESS_DATA_CONFIG);
    Map<String, dynamic> files = jsonDecode(config);
    for (var file in files["files"]) {
      if (!await IO.File('$tessdataDirectory/$file').exists()) {
        final ByteData data = await rootBundle.load('$TESS_DATA_PATH/$file');
        final Uint8List bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await IO.File('$tessdataDirectory/$file').writeAsBytes(bytes);
      }
    }
  }
}
