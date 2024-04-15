import AVFoundation
import Vision
import CoreImage


internal class DetectPieces{
    var detectionRequest:VNCoreMLRequest!
    var ready = false
    
    init(){
        Task { try self.initDetection() }
    }
    
    func initDetection()throws{
        do {
            
            guard let modelUrl = Bundle.main.url(forResource: "ChesspiecesModel", withExtension: "mlmodelc") else {
                throw DetectionError.FailedToLoadBoardSegModel
            }
            
            let configuration = MLModelConfiguration()
            
            let model = try MLModel(contentsOf: modelUrl, configuration: configuration)
        
            let VNmodel = try VNCoreMLModel(for: model)

            self.detectionRequest = VNCoreMLRequest(model: VNmodel)
            
            self.detectionRequest.imageCropAndScaleOption = .scaleFill
            
            self.ready = true
            
        } catch let error {
            NSLog("\(error)")
            throw DetectionError.FailedToLoadPiecesObjModel
        }
    }
    
    func detectAndProcess(image:CIImage)throws-> [ProcessedObservation]{
        
        let observations = try self.detect(image: image)
        
        let processedObservations = self.processObservation(observations: observations, viewSize: image.extent.size)
        
        return processedObservations
    }
    
    func detectAndProcess(image: UIImage)throws->[ProcessedObservation]{
        
        guard let ciImage = CIImage.init(image: image) else {
            throw ImageLoadError.FailedToConvertCIImage
        }
        return try self.detectAndProcess(image: ciImage)
    }
    
    func detect(image:CIImage)throws-> [VNObservation]{
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([self.detectionRequest])
            let observations = self.detectionRequest.results!
            
            return observations
            
        }catch{
            throw DetectionError.FailedToDetectPieces
        }
        
    }
    
    
    func processObservation(observations:[VNObservation], viewSize:CGSize) -> [ProcessedObservation]{
       
        var processedObservations:[ProcessedObservation] = []
        
        for observation in observations where observation is VNRecognizedObjectObservation {
            
            let objectObservation = observation as! VNRecognizedObjectObservation
                        
            let rect = objectObservation.boundingBox
            
            let flippedBox = CGRect(x: rect.minX, y: 1 - rect.maxY, width: rect.width, height: rect.height)
            
            let box = VNImageRectForNormalizedRect(flippedBox, Int(640), Int(640))

            let label = objectObservation.labels.first!.identifier
            
            let processedOD = ProcessedObservation(label: label, confidence: objectObservation.confidence, boundingBox: box)
            
            processedObservations.append(processedOD)
        }
        
        return processedObservations
        
    }

}

struct ProcessedObservation{
    var label: String
    var confidence: Float
    var boundingBox: CGRect
}
