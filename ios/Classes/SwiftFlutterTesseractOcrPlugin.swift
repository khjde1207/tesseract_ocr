import Flutter
import UIKit
import SwiftyTesseract
import VideoToolbox
import Foundation

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    
    var swiftyTesseract = SwiftyTesseract(language: .english)
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
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
        else if(call.method == "initswiftyTesseract")
        {
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            if(language != nil){
                swiftyTesseract = SwiftyTesseract(language: .custom((language as String?)!))
            }
            return true
        }
        else if (call.method == "extractTextLive"){
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let imgD: FlutterStandardTypedData? = params["imageData"] as? FlutterStandardTypedData
            
            let imageBytes : Data
            imageBytes = imgD!.data
           
            guard let image = UIImage(data: imageBytes) else { return}

            swiftyTesseract.performOCR(on: image) { recognizedString in
                        guard let extractText = recognizedString else { return }
                        NSLog(extractText)
                        result(extractText)
                    }
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





