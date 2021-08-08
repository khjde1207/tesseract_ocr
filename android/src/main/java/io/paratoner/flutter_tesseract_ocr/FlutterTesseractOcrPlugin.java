package io.paratoner.flutter_tesseract_ocr;

import com.googlecode.tesseract.android.TessBaseAPI;

import java.io.File;

import java.util.Map.*;
import java.util.Map;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.os.Handler;
import android.os.Looper;

/** FlutterTesseractOcrPlugin */
public class FlutterTesseractOcrPlugin implements MethodCallHandler {

  private static final int DEFAULT_PAGE_SEG_MODE = TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK;
  TessBaseAPI baseApi = null;
  String lastLanguage = "";
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_tesseract_ocr");
    channel.setMethodCallHandler(new FlutterTesseractOcrPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

    switch (call.method) {
      case "extractText":
      case "extractHocr":
        final String tessDataPath = call.argument("tessData");
        final String imagePath = call.argument("imagePath");
        final Map<String, String> args = call.argument("args");
        String DEFAULT_LANGUAGE = "eng";
        if (call.argument("language") != null) {
          DEFAULT_LANGUAGE = call.argument("language");
        }
        final String[] recognizedText = new String[1];
        if(baseApi == null || !lastLanguage.equals(DEFAULT_LANGUAGE)){
          baseApi = new TessBaseAPI();
          baseApi.init(tessDataPath, DEFAULT_LANGUAGE);
          lastLanguage = DEFAULT_LANGUAGE;
        }
        
        if(args != null){
          for (Map.Entry<String, String> entry : args.entrySet()) {
            baseApi.setVariable(entry.getKey(), entry.getValue());
          } 
        }

        final File tempFile = new File(imagePath);
        baseApi.setPageSegMode(DEFAULT_PAGE_SEG_MODE);

        Thread t = new Thread(new MyRunnable(baseApi, tempFile, recognizedText, result, call.method.equals("extractHocr")));
        t.start();
        break; 
      
      case "extractTextLive":
      //ToDo
      //Implement Android Side Of Live OCR.

      default:
        result.notImplemented();
    }
  }
}

class MyRunnable implements Runnable {
  private TessBaseAPI baseApi;
  private File tempFile;
  private String[] recognizedText;
  private Result result;
  private boolean isHocr;

  public MyRunnable(TessBaseAPI baseApi, File tempFile, String[] recognizedText, Result result, boolean isHocr) {
    this.baseApi = baseApi;
    this.tempFile = tempFile;
    this.recognizedText = recognizedText;
    this.result = result;
    this.isHocr = isHocr;
  }

  @Override
  public void run() {
    this.baseApi.setImage(this.tempFile);
    if (isHocr) {
      recognizedText[0] = this.baseApi.getHOCRText(0);
    } else {
      recognizedText[0] = this.baseApi.getUTF8Text();
    }
    // this.baseApi.end();
    this.baseApi.stop();
    this.sendSuccess(recognizedText[0]);
  }

  public void sendSuccess(String msg) {
    final String str = msg;
    final Result res = this.result;
    new Handler(Looper.getMainLooper()).post(new Runnable() {@Override
      public void run() {
        res.success(str);
      }
    });
  }
}
