# Tesseract OCR for Flutter

Tesseract OCR 4.0 for flutter
This plugin is based on <a href="https://github.com/tesseract-ocr/tesseract">Tesseract OCR 4</a>
This plugin uses <a href="https://github.com/adaptech-cz/Tesseract4Android/"> Tesseract4Android </a> and <a href="https://github.com/SwiftyTesseract/SwiftyTesseract">SwiftyTesseract</a>.

[pub.dev link](https://pub.dev/packages/flutter_tesseract_ocr) 

---

https://pub.dev/packages/google_ml_kit

Tesseract is slower than ml_kit.

Consider whether you should use Tesseract

---

# example
<p align='center'>
    <img src="https://raw.github.com/khjde1207/tesseract_ocr/master/example.gif" />
</p>




## install 

```

dev_dependencies:
  ...
  flutter_tesseract_ocr:

```

## web  
./web/index.html 

use https://www.npmjs.com/package/tesseract.js/v/2.1.1
```
<body>
  <script src='https://unpkg.com/tesseract.js@2.1.0/dist/tesseract.min.js'></script>
  <script>
    async function _extractText(imagePath , mapData){
      var worker = Tesseract.createWorker();
      await worker.load();
      await worker.loadLanguage(mapData.language)
      await worker.initialize(mapData.language)
      await worker.setParameters(mapData.args)
      var rtn = await worker.recognize(imagePath, {}, worker.id);
      await worker.terminate();
      if(mapData.args["tessjs_create_hocr"]){
        return rtn.data.hocr;  
      }
      return rtn.data.text;
    }
  </script>
  ...
  ..
  .
</body>
```
To add languages trained data files in web
replace `var worker = Tesseract.createWorker();` with
`var worker = Tesseract.createWorker({langPath: '../lang-data'});`
and in your web/ folder , add folder `lang-data` , and here add trained data files
also make sure that after downloading data traineddata from [here](https://github.com/tesseract-ocr/tessdata) , 
convert this file to gzip file , for example , to add eng lang ,
download `eng.traineddata` and compress this to `eng.traineddata.gz` , and add this gz to `lang-data`
---

## Getting Started (Android / Ios)

You must add trained data and trained data config file to your assets directory.
You can find additional language trained data files here <a href="https://github.com/tesseract-ocr/tessdata">Trained language files</a>

add tessdata folder under assets folder, add tessdata_config.json file under assets folder:

```
{
  "files": [
    "eng.traineddata",
    "<other_language>.traineddata"
  ]
}
```

Plugin assumes you have tessdata folder in your assets directory and defined in your pubspec.yaml

Check the contents of example/assets folder and example/pubspec.yaml

---
## IOS issues

[Initialization of SwiftyTesseract has failed](https://github.com/khjde1207/tesseract_ocr/issues/16)

Just drag tessdata folder from asset to place under Runner folder in xcode add as a reference then it will work.

[Reference](https://github.com/arrrrny/tesseract_ocr/issues/31)

---

## Usage

Using is very simple:

```
//args support android / Web , i don't have a mac 
String text = await FlutterTesseractOcr.extractText('/path/to/image', language: 'kor+eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });

```

You can leave `language` empty, it will default to `'eng'.

```
//---- dynamic add Tessdata (Android)---- ▼ 
// https://github.com/tesseract-ocr/tessdata/raw/main/dan_frak.traineddata

HttpClient httpClient = new HttpClient();

HttpClientRequest request = await httpClient.getUrl(Uri.parse(
        'https://github.com/tesseract-ocr/tessdata/raw/main/${langName}.traineddata'));

HttpClientResponse response = await request.close();
Uint8List bytes =await consolidateHttpClientResponseBytes(response);
String dir = await FlutterTesseractOcr.getTessdataPath();

print('$dir/${langName}.traineddata');
File file = new File('$dir/${langName}.traineddata');
await file.writeAsBytes(bytes);
//---- dynamic add Tessdata ---- ▲

```



