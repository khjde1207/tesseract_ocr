library flutter_tesseract_ocr;

export '/models/models.dart';
export 'android_ios.dart' // Stub implementation
    if (dart.library.html) 'web.dart'; // dart:html implementation
