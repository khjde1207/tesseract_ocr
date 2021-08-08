import 'dart:typed_data';

import 'package:example/camera_view.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class TextDetectorView extends StatefulWidget {
  @override
  _TextDetectorViewState createState() => _TextDetectorViewState();
}

class _TextDetectorViewState extends State<TextDetectorView> {
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Text Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      ocrData: '',
    );
  }

  Future<void> processImage(imglib.Image inputImage) async {
    if (isBusy) return;
    isBusy = true;
    // var croppedImage = imglib.copyCrop(inputImage, 0, 0, 200, 200);
    var imgData = imglib.encodeJpg(inputImage);

    final recognisedText =
        await FlutterTesseractOcr.extractTextLive(Uint8List.fromList(imgData));
    print(recognisedText);

    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
