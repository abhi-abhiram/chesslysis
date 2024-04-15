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
import Algorithms

public class MlModule: Module {
    typealias LoadImageCallback = (Result<UIImage, Error>) -> Void
    
    var image:UIImage?
    let piecesDetector = DetectPieces()
    var segment:DetectBoard?
//    let labeler = Labeling()
    
    
    public func definition() -> ModuleDefinition {
        Name("MlModule")
        
        AsyncFunction("predict") {
            (url:URL, promise:Promise)  in
            Task.init {
                do {
                    let result = try await predict(for:url)
                    promise.resolve(result)
                } catch let error {
                    promise.reject("Failed to Detect", error.localizedDescription)
                }
            }
        }
        
        OnCreate {
            do{
                self.segment = try DetectBoard()
            }catch let error {
                NSLog("\(error)")
            }
        }
        
    }
    
    internal func predict(for url:URL) async throws -> String {
        
        let image = try await loadImage(atUrl: url)
        
        guard let cgImage =  image.cgImage else {
            throw ImageLoadError.CGImageNotFound
        }
        
        guard let gray_img = try Utils.convertToGrayScale(image: image) else {
            throw ImageLoadError.FailedToConvertGrayScale
        }
        
        guard let obs = try self.segment?.detectAndProcess(image:gray_img) else {
            throw DetectionError.FailedToLoadBoardSegModel
        }
        
        NSLog("Detection completed")
        
        if obs.count == 0 {
            NSLog("No Board detected")
            throw DetectionError.FailedToDetectBoard
        }
        
        let board = obs[0]
        
        let mask = board.getMaskImage()
        
        let thresholdFilter = CIFilter.colorThreshold()
        let filter1 = CIFilter.morphologyRectangleMinimum()
        let filter2 = CIFilter.morphologyRectangleMaximum()
        
        filter1.width = 11
        filter1.height = 11
        filter2.width = 11
        filter2.height = 11
        
        
        let  filter3 = CIFilter.morphologyRectangleMaximum()
        let filter4 = CIFilter.morphologyRectangleMinimum()
        
        filter3.width = 5
        filter3.height = 5
        filter4.width = 5
        filter4.height = 5
        
        thresholdFilter.inputImage = CIImage.init(cgImage: mask!.cgImage!)
        filter1.inputImage = thresholdFilter.outputImage
        filter2.inputImage = filter1.outputImage
        
        
        filter3.inputImage = filter2.outputImage
        filter4.inputImage = filter3.outputImage
        
        let result =  UIImage(ciImage: filter4.outputImage!).resize(to: CGSize(width: cgImage.width, height: cgImage.height))
        
        let inputImage = CIImage.init(cgImage: result.cgImage!)
        
        let contourRequest = VNDetectContoursRequest.init()
        
        contourRequest.revision = VNDetectContourRequestRevision1
        contourRequest.contrastAdjustment = 1.0
        contourRequest.detectsDarkOnLight = true
        contourRequest.maximumImageDimension = 640
        
        
        let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])
        
        try requestHandler.perform([contourRequest])
        
        guard let contoursObservation = contourRequest.results?.first else {
            throw DetectionError.FailedToDetectBoard
        }
        
        var largestContour: VNContour?
        var largestArea: Double = 0
        
        try contoursObservation.topLevelContours.first?.childContours.forEach({ contour in
            var area:Double = 0
            try VNGeometryUtils.calculateArea(&area, for: contour, orientedArea: false)
            if (largestArea < area) {
                largestContour = contour
                largestArea = area
            }
        })
        
        guard let boardContour = try largestContour?.polygonApproximation(epsilon: 0.01) else {
            throw DetectionError.FailedToDetectBoard
        }
        
        let points = boardContour.normalizedPoints.map({ point in
            return Utils.convertNormalizedToCartesian(normalizedPoint: CGPoint(x: CGFloat(point.x.magnitude) , y: CGFloat(point.y.magnitude)) , viewSize: image.size)
        })
        
        var maxArea = -1.0
        
        var maxAreaPoints:[CGPoint]?
        
        
        for var combo in points.combinations(ofCount: 4) {
            combo.sort { p1, p2 in
                return p1.y < p2.y
            }
            
            if (combo[0].x > combo[1].x){
                let temp = combo[0]
                combo[0] = combo[1]
                combo[1] = temp
            }
            
            if (combo[2].x < combo[3].x){
                let temp = combo[2]
                combo[2] = combo[3]
                combo[3] = temp
            }
            
            let area = Utils.areaQuad(points: combo).magnitude
            
            if (maxArea < area) {
                maxArea = area
                maxAreaPoints = combo
            }
        }
        
        guard maxAreaPoints != nil else {
            throw DetectionError.FailedToDetectBoard
        }
        
        let boardImage =  Utils.perspectiveCorrection(inputImage: CIImage(cgImage: cgImage), points: maxAreaPoints!)
        
        let pieces = try piecesDetector.detectAndProcess(image: boardImage)
        
        var positions = [[Character?]](repeating: [Character?](repeating: nil, count: 8), count: 8)

        pieces.forEach { p in
            let x = (p.boundingBox.minX + p.boundingBox.maxX)/2
            let y = (p.boundingBox.minY + p.boundingBox.maxY)/2
            
            let i = Int(x / 80)
            let j = Int(y / 80)
            
            positions[j][i] = Character(p.label)
        }
        
//        let labeledImage = labeler.labelImage(image: UIImage(ciImage: boardImage), observations: pieces)!
        
        return try await getImageUrl(for: UIImage(ciImage:  boardImage))
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
        
        try data?.write(to: url, options: [.atomic])
        
        return url.absoluteString
    }
}
