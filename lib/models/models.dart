import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

// To indicate the format of image while creating input image from bytes
enum InputImageFormat { NV21, YV12, YUV_420_888, YUV420, BGRA8888 }

extension InputImageFormatMethods on InputImageFormat {
  // source: https://developers.google.com/android/reference/com/google/mlkit/vision/common/InputImage#constants
  static Map<InputImageFormat, int> get _values => {
        InputImageFormat.NV21: 17,
        InputImageFormat.YV12: 842094169,
        InputImageFormat.YUV_420_888: 35,
        InputImageFormat.YUV420: 875704438,
        InputImageFormat.BGRA8888: 1111970369,
      };

  int get rawValue => _values[this] ?? 17;

  static InputImageFormat? fromRawValue(int rawValue) {
    return InputImageFormatMethods._values
        .map((k, v) => MapEntry(v, k))[rawValue];
  }
}

// The camera rotation angle to be specified
enum InputImageRotation {
  Rotation_0deg,
  Rotation_90deg,
  Rotation_180deg,
  Rotation_270deg
}

extension InputImageRotationMethods on InputImageRotation {
  static Map<InputImageRotation, int> get _values => {
        InputImageRotation.Rotation_0deg: 0,
        InputImageRotation.Rotation_90deg: 90,
        InputImageRotation.Rotation_180deg: 180,
        InputImageRotation.Rotation_270deg: 270,
      };

  int get rawValue => _values[this] ?? 0;

  static InputImageRotation? fromRawValue(int rawValue) {
    return InputImageRotationMethods._values
        .map((k, v) => MapEntry(v, k))[rawValue];
  }
}

/// [InputImage] is the format flutter_tesseract_ocr takes to process the image
class InputImage {
  InputImage._(
      {String? filePath,
      Uint8List? bytes,
      required String imageType,
      InputImageData? inputImageData})
      : filePath = filePath,
        bytes = bytes,
        imageType = imageType,
        inputImageData = inputImageData;

  /// Create InputImage from path of image stored in device.
  factory InputImage.fromFilePath(String path) {
    return InputImage._(filePath: path, imageType: 'file');
  }

  /// Create InputImage by passing a file.
  factory InputImage.fromFile(File file) {
    return InputImage._(filePath: file.path, imageType: 'file');
  }

  /// Create InputImage using bytes.
  factory InputImage.fromBytes(
      {required Uint8List bytes, required InputImageData inputImageData}) {
    return InputImage._(
        bytes: bytes, imageType: 'bytes', inputImageData: inputImageData);
  }

  final String? filePath;
  final Uint8List? bytes;
  final String imageType;
  final InputImageData? inputImageData;

  Map<String, dynamic> getImageData() {
    var map = <String, dynamic>{
      'bytes': bytes,
      'type': imageType,
      'path': filePath,
      'metadata':
          inputImageData == null ? 'none' : inputImageData!.getMetaData()
    };
    return map;
  }
}

/// Data of image required when creating image from bytes.
class InputImageData {
  /// Size of image.
  final Size size;

  /// Image rotation degree.
  final InputImageRotation imageRotation;

  /// Format of the input image.
  final InputImageFormat inputImageFormat;

  /// The plane attributes to create the image buffer on iOS.
  ///
  /// Not used on Android.
  final List<InputImagePlaneMetadata>? planeData;

  InputImageData(
      {required this.size,
      required this.imageRotation,
      required this.inputImageFormat,
      required this.planeData});

  /// Function to get the metadata of image processing purposes
  Map<String, dynamic> getMetaData() {
    var map = <String, dynamic>{
      'width': size.width,
      'height': size.height,
      'rotation': imageRotation.rawValue,
      'imageFormat': inputImageFormat.rawValue,
      'planeData': planeData
          ?.map((InputImagePlaneMetadata plane) => plane._serialize())
          .toList(),
    };
    return map;
  }
}

/// Plane attributes to create the image buffer on iOS.
///
/// When using iOS, [height], and [width] throw [AssertionError]
/// if `null`.
class InputImagePlaneMetadata {
  InputImagePlaneMetadata({
    required this.bytesPerRow,
    this.height,
    this.width,
  });

  /// The row stride for this color plane, in bytes.
  final int bytesPerRow;

  /// Height of the pixel buffer on iOS.
  final int? height;

  /// Width of the pixel buffer on iOS.
  final int? width;

  Map<String, dynamic> _serialize() => <String, dynamic>{
        'bytesPerRow': bytesPerRow,
        'height': height,
        'width': width,
      };
}

///Class that gives the detected text.
///Recognised text hierarchy.
///Recognised Text ---> List<TextBlock> (Blocks of text identified in the image).
///TextBlock ---> List<TextLine> (Lines of text present in a certain identified block).
///TextLine ---> List<TextElement> (Fundamental part of a block i.e usually a word or sentence)
class RecognisedText {
  RecognisedText._(this.text, this.blocks);

  factory RecognisedText.fromMap(Map<dynamic, dynamic> map) {
    var resText = map["text"];
    var textBlocks = <TextBlock>[];
    for (var block in map["blocks"]) {
      var textBlock = TextBlock.fromMap(block);
      textBlocks.add(textBlock);
    }
    return RecognisedText._(resText, textBlocks);
  }

  ///String containing all the text identified in a image.
  final String text;

  ///All the blocks of text present in image.
  final List<TextBlock> blocks;
}

///Class that has a block or group of words present in part of image.
class TextBlock {
  TextBlock._(this.text, this.lines, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextBlock.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(map['recognizedLanguages']);
    final points = _listToCornerPoints(map['points']);
    final lines = <TextLine>[];
    for (var line in map['lines']) {
      final textLine = TextLine.fromMap(line);
      lines.add(textLine);
    }
    return TextBlock._(text, lines, rect, recognizedLanguages, points);
  }

  ///Text in the block.
  final String text;

  ///List of sentences.
  final List<TextLine> lines;

  ///Rect outlining boundary of block.
  final Rect rect;

  ///List of recognized Latin-based languages in the text block.
  final List<String> recognizedLanguages;

  ///List of corner points of the rect.
  final List<Offset> cornerPoints;
}

///Class that represents sentence present in a certain block.
class TextLine {
  TextLine._(this.text, this.elements, this.rect, this.recognizedLanguages,
      this.cornerPoints);

  factory TextLine.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final recognizedLanguages =
        _listToRecognizedLanguages(map['recognizedLanguages']);
    final points = _listToCornerPoints(map['points']);
    final elements = <TextElement>[];
    for (var element in map['elements']) {
      final textElement = TextElement.fromMap(element);
      elements.add(textElement);
    }
    return TextLine._(text, elements, rect, recognizedLanguages, points);
  }

  ///Sentence of a block.
  final String text;

  ///List of text element.
  final List<TextElement> elements;

  ///Rect outlining the the text line.
  final Rect rect;

  ///List of recognized Latin-based languages in the text block.
  final List<String> recognizedLanguages;

  ///Corner points of the text line.
  final List<Offset> cornerPoints;
}

///Fundamental part of text detected.
class TextElement {
  TextElement._(this.text, this.rect, this.cornerPoints);

  factory TextElement.fromMap(Map<dynamic, dynamic> map) {
    final text = map['text'];
    final rect = _mapToRect(map['rect']);
    final points = _listToCornerPoints(map['points']);
    return TextElement._(text, rect, points);
  }

  ///String representation of the text element that was recognized.
  final String text;

  ///Rect outlining the boundary of element.
  final Rect rect;

  ///List of corner points of the element.
  final List<Offset> cornerPoints;
}

///Convert list of Object? to list of Strings.
List<String> _listToRecognizedLanguages(List<dynamic> languages) {
  var recognizedLanguages = <String>[];
  for (var obj in languages) {
    if (obj != null) {
      recognizedLanguages.add(obj);
    }
  }
  return recognizedLanguages;
}

///Convert map to Rect.
Rect _mapToRect(Map<dynamic, dynamic> rect) {
  var rec = Rect.fromLTRB((rect["left"]).toDouble(), (rect["top"]).toDouble(),
      (rect["right"]).toDouble(), (rect["bottom"]).toDouble());
  return rec;
}

///Convert list of map to list of offset.
List<Offset> _listToCornerPoints(List<dynamic> points) {
  var p = <Offset>[];
  for (var point in points) {
    p.add(Offset((point['x']).toDouble(), (point['y']).toDouble()));
  }
  return p;
}
