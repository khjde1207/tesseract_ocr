## 0.4.29
 -Wasm support #55 

## 0.4.27
- move to flutter gradle's declarative plugins

## 0.4.26
- Fixing Compile Issue error

## 0.4.23

- Update flutter_tesseract_ocr.podspec

## 0.4.22

- Build with latest version of Tesseract4Android
- Change to latest version of web tesseract

## 0.4.20

- ios version up to 12.0

## 0.4.19

- Fixing Calling multiple async calls crashing bug

## 0.4.17

- Migrating to Android embedding V2 for flutter

## 0.4.16

- edit readme

## 0.4.13

- rollback, remove liveocr
- fixes I had this problem when I called the menthod again, the first call was successful
- fixes Web: No Such Method Exception
- add try-catch fixes #13

## 0.4.12

- fixes I had this problem when I called the menthod again, the first call was successful

## 0.4.12

- fixes Web: No Such Method Exception

## 0.4.10

- fixes TessBaseAPI was not terminated using recycle()

## 0.4.9

- fixes web error (Error: Method not found: 'FlutterTesseractOcr.extractTextLive')

## 0.4.8

- add try-catch / edit readme

## 0.4.7

- add try-catch fixes #13

## 0.4.6

- add live ocr (IOS)

## 0.4.4

- add gif

## 0.4.2

- working on IOS (https://github.com/khjde1207/tesseract_ocr/issues/5)

## 0.4.2

- fixes error NoSuchMethodError: The method 'containsKey' was called on null

## 0.4.0

- Performance improvement (0.2 seconds faster per page than before)

## 0.3.8

- support web

## 0.3.7

- Support latest gradle

## 0.3.4

- TesseractOcr -> FlutterTesseractOcr

## 0.3.0

- added language support you can pass the language as an optional parameter. TesseractOcr.extractText(imagePath, language: "financial");
  if not set it will default to "eng". language must match the name of .traineddata file

## 0.1.0

- Extract Text from images, Especially helpful when you are extracting single character images.

## 0.1.1

- fixed path references

## 0.1.2

- added description

## 0.1.2+1

- fixed typo

## 0.1.2+2

- fixed description

## 0.1.2+3

- added LICENSE

## 0.1.3

- updated swift version to 4.2

## 0.2.0

- fixed dependecies

## 0.2.1

- fixed swift version

## 0.2.2

- set target swift version to 4.2
