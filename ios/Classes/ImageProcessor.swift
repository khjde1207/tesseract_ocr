

// func UIImageFromImageData(imageData: NSDictionary) -> UIImage {

// let params: [String : Any] = NSDictionary as! [String : Any]
// let imageType: String? = params["type"] as? String
// let imagePath: String? = params["path"] as? String
// let imageBytes: FlutterStandardTypedData? = params["bytes"] as? FlutterStandardTypedData

    
//     if ("file".isEqualToString(imageType)) {
//         return filePathToVisionImage(imagePath);
//     } else if ("bytes".isEqualToString(imageType)) {
//         return bytesToVisionImage(imageBytes);
//     } else {
//         ////////
//         ///ToDo
//         ///handle Expetion later
//         ///////

//        NSLog("Invalid Image type")
//     }

// }

// func filePathToVisionImage(filePath :String)-> UIImage {

//   return UIImage(contentsOfFile: filePath);

// }

// func bytesToVisionImage(imageData: FlutterStandardTypedData ) {
//     let imageBytes = NSData(bytes: imageData, length: imageData.length)
    
//     return UIImage(data: imageBytes)
// }
