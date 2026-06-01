import Flutter
import UIKit
import SwiftyTesseract

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        initializeTessData()
        if call.method == "extractText" {
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            let imagePath = params["imagePath"] as! String
            guard let image = UIImage(contentsOfFile: imagePath) else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var swiftyTesseract = SwiftyTesseract(language: .english)
                if let language = language {
                    swiftyTesseract = SwiftyTesseract(language: .custom(language))
                }
                
                swiftyTesseract.performOCR(on: image) { recognizedString in
                    DispatchQueue.main.async {
                        guard let extractText = recognizedString else { return }
                        result(extractText)
                    }
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
}
