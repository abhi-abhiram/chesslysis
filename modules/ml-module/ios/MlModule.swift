//
//  MLModule.swift
//  MlModule
//
//  Created by Anukoola abhiram on 27/02/24.
import ExpoModulesCore
import Vision
import Photos
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

let DETECTION_COMPLETED_EVENT_NAME = "onDetectionComplete"


@available(iOS 15.0, *)
public class MlModule: Module {
    typealias LoadImageCallback = (Result<UIImage, Error>) -> Void
    
    var image:UIImage?
    var detector = DetectPieces()
    var segment = DetectBoard()
    
    public func definition() -> ModuleDefinition {
        Name("MlModule")
        Events(DETECTION_COMPLETED_EVENT_NAME)
        
        AsyncFunction("predict") {
            (url:URL, promise:Promise)  in
            Task.init {
                do {
                    let result = try await predict(for:url)
                    promise.resolve(result)
                } catch let error as ImageLoadError {
                    var msg:String
                    switch (error) {
                    case .LoadingFailed:
                        msg = "Loading Failed"
                    case .NotFound:
                        msg = "Not Found"
                    case .CGImageNotFound:
                        msg = "CGIImage not Found"
                    }
                    promise.reject("ImageLoadError", msg)
                }
            }
        }
        
    }
    
    internal func predict(for url:URL) async throws -> String {
        
        let image = try await loadImage(atUrl: url)
        guard let cgImage =  image.cgImage else {
            throw ImageLoadError.CGImageNotFound
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let obs = self.segment.detectAndProcess(image:ciImage)
        
        let board = obs[0]
        
        let mask = board.getMaskImage()
        
        let result = mask?.resize(to: CGSize(width: cgImage.width, height: cgImage.height))
        
        var inputImage = CIImage.init(cgImage: result!.cgImage!)
        
        let contourRequest = VNDetectContoursRequest.init()
        
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.detectsDarkOnLight = true
        contourRequest.maximumImageDimension = 640
        
        
        let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])
        
        try! requestHandler.perform([contourRequest])
        
        let contoursObservation = contourRequest.results?.first!
        
        var largestContour: VNContour?
        var largestArea: Double = 0
        
    
        try contoursObservation?.topLevelContours.first?.childContours.forEach({ contour in
            var area:Double = 0
            try VNGeometryUtils.calculateArea(&area, for: contour, orientedArea: false)
            if (largestArea < area) {
                largestContour = contour
                largestArea = area
            }
        })
        
        let boardContour = try largestContour?.polygonApproximation(epsilon: 0.1)
    
        return try await getImageUrl(for: drawContours(path: boardContour!.normalizedPath, sourceImage: cgImage))
    }
    
    /**
     Loads the image from given URL.
     */
    internal func loadImage(atUrl url: URL) async throws -> UIImage{
        if url.scheme == "data" {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                throw ImageLoadError.NotFound
            }
            return image
        }
        
        if url.scheme == "assets-library" {
            // TODO: ALAsset URLs are deprecated as of iOS 11, we should migrate to `ph://` soon.
            //         return loadImageFromPhotoLibrary(url: url, callback: callback)
        }
        
        guard let imageLoader = self.appContext?.imageLoader else {
            throw ImageLoadError.NotFound
        }
        
        guard let image = try await imageLoader.loadImage(for: url) else {
            throw ImageLoadError.LoadingFailed
        }
        
        
        return image
    }
    
    /**
     Loads the image from user's photo library.
     */
    internal func loadImageFromPhotoLibrary(url: URL, callback: @escaping LoadImageCallback) {
        guard let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject else {
            return callback(.failure(ImageNotFoundException()))
        }
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let options = PHImageRequestOptions()
        
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, _ in
            guard let image = image else {
                return callback(.failure(ImageNotFoundException()))
            }
            return callback(.success(image))
        }
    }
    
    internal func getImageUrl(for image:UIImage) async throws -> String{
        let data = image.jpegData(compressionQuality: 1.0)
        
        guard let fileSystem = self.appContext?.fileSystem else {
            throw PredictError.FileSystemNotFound
        }
        
        let directory =  fileSystem.cachesDirectory.appending(
            fileSystem.cachesDirectory.hasSuffix("/") ? "" : "/" + "Chesslysis"
        )
        
        let path = fileSystem.generatePath(inDirectory: directory, withExtension: ".jpg")
        
        
        let url = URL(fileURLWithPath: path)
        
        
        // TODO: Compelte image transfer
        try data?.write(to: url, options: [.atomic])
        
        return url.absoluteString
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func drawContours(path:CGPath, sourceImage: CGImage) -> UIImage {
            let size = CGSize(width: sourceImage.width, height: sourceImage.height)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let renderedImage = renderer.image { (context) in
            let renderingContext = context.cgContext

            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
            renderingContext.concatenate(flipVertical)

            renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            renderingContext.scaleBy(x: size.width, y: size.height)
            renderingContext.setLineWidth(5.0 / CGFloat(size.width))
            let redUIColor = UIColor.red
            renderingContext.setStrokeColor(redUIColor.cgColor)
            renderingContext.addPath(path)
            renderingContext.strokePath()
            }
            
            return renderedImage
        }
    
    func perspectiveCorrection(inputImage: CIImage,topRight:CGPoint, topLeft:CGPoint, bottomRight:CGPoint, bottomLeft:CGPoint) -> CIImage {
        let perspectiveCorrectionFilter = CIFilter.perspectiveCorrection()
        perspectiveCorrectionFilter.inputImage = inputImage
        perspectiveCorrectionFilter.topRight = topRight
        perspectiveCorrectionFilter.topLeft = topLeft
        perspectiveCorrectionFilter.bottomRight = bottomRight
        perspectiveCorrectionFilter.bottomLeft = bottomLeft
        return perspectiveCorrectionFilter.outputImage!
    }
}
