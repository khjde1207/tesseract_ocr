import Flutter
import UIKit
import SwiftyTesseract
import VideoToolbox
import Foundation

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
//    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
//        let iD = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
//        NSLog((iD?.base64EncodedString())!)
//        let image = UIImage(data: iD!)
//        return image!
//    }
    
    func pxBufferToCGImage(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
      }
    
    func UIImageFromImageData(imageData: NSDictionary) -> UIImage? {

        let params: [String : Any] = imageData as! [String : Any]
        let imageType: String? = params["type"] as? String
        let imagePath: String? = params["path"] as? String
        
        if ("file" == imageType) {
            return filePathToImage(filePath: imagePath!);
        }
        else if("bytes" == imageType)
        {
            if(params.count > 0)
            {
            return bytesToImage(imageData: params)!;
            }else
            {
                return nil
            }
        }
       else {
          NSLog("Invalid Image type")
          return nil
       }
    }

    func filePathToImage(filePath : String)-> UIImage {
            return UIImage(contentsOfFile: filePath)!
    }
    
    let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
       if let ptr = ptr {
         free(UnsafeMutableRawPointer(mutating: ptr))
       }
     }
    
  
    func bytesToPixelBuffer(width: Int, height: Int, format: FourCharCode,baseAddress : UnsafeMutableRawPointer, bytesPerRow: Int) -> CVBuffer?{
        var dstPixelBuffer: CVBuffer?
//        NSLog("Width of Image is: " + String(width))
//        NSLog("Height of Image is: " + String(height))
//        NSLog("Format of Image is: " + String(format))

//        NSLog("Base Address is: "+String(baseAddress.hashValue));
//
//        NSLog("Bytes Per Row are: "+String(bytesPerRow))
        
         CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, 1111970369, baseAddress, bytesPerRow,
                                                nil, nil, nil, &dstPixelBuffer)
        return dstPixelBuffer ?? nil

    }

//    func planarBytesToPixelBuffer() -> CVPixelBuffer{
//
//    }
//
   func pixelBufferToCIImage(pixelBufferRef: CVPixelBuffer) -> UIImage{
    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBufferRef))
    return image
   }

//    func pixelBufferToCGImage(pixelBufferRef: CVPixelBuffer) -> UIImage{
//     let image = UIImage(ciImage: CGImage(cvPixelBuffer: pixelBufferRef))
//     return image
//    }
    
    func bytesToImage(imageData: [String : Any]) -> UIImage?{
        
          let imgD: FlutterStandardTypedData? = imageData["bytes"] as? FlutterStandardTypedData
        let imageBytes : Data
        imageBytes = imgD!.data

//        NSLog(imageBytes.base64EncodedString())
//           return UIImage(data: imgD!.data)!
            
           let metadata: [String : Any] = imageData["metadata"] as! [String : Any]
    
           let planeData = metadata["planeData"] as! Array<Any>
           let planeCount = planeData.count
    
           let width = metadata["width"] as! Int
           let height = metadata["height"] as! Int
    
    
           let rawFormat = metadata["imageFormat"] as! NSNumber
//        NSLog("CharCode Received in IOS: "+rawFormat.stringValue)
           let format = fourCharCode(from: rawFormat.stringValue)
            
        let pxBuffer: CVPixelBuffer?;

            if(planeCount==0)
            {
//                return UIImage()
                //Throw Exception planes should be greated than Zero
                return nil
            }
            else if (planeCount==1)
            {
                let plane: [String : Any] = planeData[0] as! [String : Any]
                let bytesPerRow = plane["bytesPerRow"] as! Int
                let bytesData : UnsafeMutableRawBufferPointer
                let nsData = imageBytes as NSData
                let rawPtr = nsData.bytes
                let b:UnsafeMutableRawPointer = UnsafeMutableRawPointer(mutating:rawPtr)
                
                pxBuffer =  bytesToPixelBuffer(width: width, height: height, format: format, baseAddress: b, bytesPerRow: bytesPerRow)
                if pxBuffer != nil {
                    return UIImage(cgImage: pxBufferToCGImage(pixelBuffer: pxBuffer!)!)
//                    return  pixelBufferToCIImage(pixelBufferRef: pxBuffer!)
                }
                
            }
            else
            {
//                pxBuffer = planarBytesToPixelBuffer()
            }
        
//        NSLog("Number of Plane Counts: " + String(planeCount))


        
        return UIImage()
    }
        
    func fourCharCode(from string : String) -> FourCharCode
    {
        return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // initializeTessData()
        if (call.method == "extractText" ){
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            var swiftyTesseract = SwiftyTesseract(language: .english)
            if(language != nil){
                swiftyTesseract = SwiftyTesseract(language: .custom((language as String?)!))
            }
            let  imagePath = params["imagePath"] as! String
            guard let image = UIImage(contentsOfFile: imagePath)else { return }
            let timestamp = NSDate().timeIntervalSince1970
//            NSLog("Start OCR: "+String(timestamp))
            swiftyTesseract.performOCR(on: image) { recognizedString in
                
                guard let extractText = recognizedString else { return }
                
                let timest = NSDate().timeIntervalSince1970
//                NSLog("End OCR: "+String(timest))
                result(extractText)
//                NSLog(extractText)
            }
        }
        else if (call.method == "extractTextFromImageData" ){
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            let imageData: [String : Any] = params["imageData"] as! [String : Any]
            let metadata: [String : Any] = imageData["metadata"] as! [String : Any]
     
            let width = metadata["width"] as! Int
            let height = metadata["height"] as! Int

            var swiftyTesseract = SwiftyTesseract(language: .english)
            // if(language != nil){
            //     swiftyTesseract = SwiftyTesseract(language: .custom(language as String!))
            // }
            guard let image = UIImageFromImageData(imageData: imageData as NSDictionary ) else { return }
            let rect = CGRect(
                origin: CGPoint(x: 0, y: 0), size: CGSize(width: 400, height: 400)
                );
            
            
            guard let croppedImage :  UIImage = cropImage(image, toRect: rect, viewWidth: CGFloat(width), viewHeight: CGFloat(height)) else { result("Error at Image rect")
                return }
            
            
            //UnComment Below Line to Save Cropped Image to Photo Library.
//            UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
//
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            let timestamp = NSDate().timeIntervalSince1970
//            NSLog("Start OCR: "+String(timestamp))
            
             swiftyTesseract.performOCR(on: image) { recognizedString in
                 guard let extractText = recognizedString else { return }
                NSLog(extractText)
                result(extractText)
                let timest = NSDate().timeIntervalSince1970
//                NSLog("End OCR: "+String(timest))
//            result("imageData")
            
             }
        }
    }
    
    func initializeTessData() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent("tessdata")
        
        let sourceURL = Bundle.main.bundleURL.appendingPathComponent("tessdata")
        
        let fileManager = FileManager.default
        do {
            try fileManager.createSymbolicLink(at: sourceURL, withDestinationURL: destURL)
        } catch {
            print(error)
        }
    }


}


