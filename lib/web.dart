import 'dart:async';
import 'dart:js_interop';

@JS('_extractText')
external JSPromise<JSAny?> _extractText(JSAny imagePath, JSAny args);

// FlutterTesseractOcr Class
class FlutterTesseractOcr {
  /// image to  text
  ///```
  /// String _ocrText = await FlutterTesseractOcr.extractText(url, language: langs, args: {
  ///    "preserve_interword_spaces": "1",});
  ///```
  static Future<String> extractText(String imagePath,
      {String? language, Map? args}) async {
    final data = {
      "language": language,
      // To avoid error when we pass null to args
      "args": args ?? {},
    };

    var promiseData = _extractText(imagePath.toJS, (data).jsify()!);

    return promiseData.toDart.then((v) => v.dartify() as String);
  }

  /// image to  html text(hocr)
  ///```
  /// String _ocrHocr = await FlutterTesseractOcr.extractText(url, language: langs, args: {
  ///    "preserve_interword_spaces": "1",});
  ///```
  static Future<String> extractHocr(String imagePath,
      {String? language, Map? args}) async {
    final data = {
      "language": language,
      // To avoid error when we pass null to args
      "args": {...args ?? {}, "tessjs_create_hocr": "1"}
    };

    var promiseData = _extractText(
      imagePath.toJS,
      data.jsify()!,
    );

    return promiseData.toDart.then((v) => v.dartify() as String);
  }

  //web not support
  static Future<String> getTessdataPath() async {
    return "";
  }

  //web not support
  static Future<String> _loadTessData() async {
    return "";
  }

  //web not support
  static Future _copyTessDataToAppDocumentsDirectory(
      String tessdataDirectory) async {}
}
