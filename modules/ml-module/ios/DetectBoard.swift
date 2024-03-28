//
//  Segment.swift
//  MlModule
//
//  Created by Anukoola abhiram on 24/03/24.
//

import AVFoundation
import Vision
import CoreImage

@available(iOS 15.0, *)
internal class DetectBoard{
    var detectionRequest:VNCoreMLRequest!
    var ready = false
    let confidenceThreshold:Float = 0.3
    let iouThreshold: Float = 0.6
    var maskThreshold: Float = 0.5
    
    init(){
        Task { self.initDetection() }
    }
    
    func initDetection(){
        do {
            guard let modelUrl = Bundle.main.url(forResource: "ChesssegModel", withExtension: "mlmodelc") else {
                throw ModelLoadFailedException()
            }
            
            let configuration = MLModelConfiguration()
            
            let model = try MLModel(contentsOf: modelUrl, configuration: configuration)
        
            let VNmodel = try VNCoreMLModel(for: model)

            self.detectionRequest = VNCoreMLRequest(model: VNmodel)
            
            self.detectionRequest.imageCropAndScaleOption = .scaleFill
            
            self.ready = true
        } catch let error {
            fatalError("failed to setup model: \(error)")
        }
    }
    
    func detectAndProcess(image:CIImage)-> [MaskPrediction]{
        
        let observations = self.detect(image: image)
        
        let boxesOutput = observations[1] as! VNCoreMLFeatureValueObservation
        
        let masksOutput = observations[0] as! VNCoreMLFeatureValueObservation
        
        let boxes = boxesOutput.featureValue.multiArrayValue!
        
        let numSegmentationMasks = 32
        
        let numClasses = Int(truncating: boxes.shape[1]) - 4 - numSegmentationMasks
        
        var predictions = getPredictionsFromOutput(output: boxes, rows: Int(truncating: boxes.shape[1]), columns: Int(truncating: boxes.shape[2]), numberOfClasses: numClasses, inputImgSize: CGSize(width:  640, height: 640))
    
        predictions.removeAll { $0.score < confidenceThreshold }
        
        let groupedPredictions = Dictionary(grouping: predictions) { prediction in
            prediction.classIndex
        }
        
        var nmsPredictions: [Prediction] = []
        
        let _ = groupedPredictions.mapValues { predictions in
            nmsPredictions.append(
                contentsOf: nonMaximumSuppression(
                    predictions: predictions,
                    iouThreshold: iouThreshold,
                    limit: 100))
        }
        
        let masks = masksOutput.featureValue.multiArrayValue!
        
        let maskProtos = getMaskProtosFromOutput(
            output: masks,
            rows: Int(truncating: masks.shape[3]),
            columns: Int(truncating: masks.shape[2]),
            tubes: Int(truncating: masks.shape[1])
        )
        
        
        let maskPredictions = masksFromProtos(
            boxPredictions: nmsPredictions,
            maskProtos: maskProtos,
            maskSize: (
                width: Int(truncating: masks.shape[3]),
                height: Int(truncating: masks.shape[2])
            ),
            originalImgSize: CGSize(width: image.cgImage!.width, height: image.cgImage!.height)
        )
      
        return maskPredictions
    }
    
    
    func detect(image:CIImage) -> [VNObservation]{
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([self.detectionRequest])
            let observations = self.detectionRequest.results!
            
            return observations
            
        }catch let error{
            fatalError("failed to detect: \(error)")
        }
    }
    
    func getPredictionsFromOutput(
        output: MLMultiArray,
        rows: Int,
        columns: Int,
        numberOfClasses: Int,
        inputImgSize: CGSize
    ) -> [Prediction] {
        guard output.count != 0 else {
            return []
        }
        var predictions = [Prediction]()
        for i in 0..<columns {
            let centerX = Float(truncating: output[0*columns+i])
            let centerY = Float(truncating: output[1*columns+i])
            let width   = Float(truncating: output[2*columns+i])
            let height  = Float(truncating: output[3*columns+i])
            
            let (classIndex, score) = {
                var classIndex: Int = 0
                var heighestScore: Float = 0
                for j in 0..<numberOfClasses {
                    let score = Float(truncating: output[(4+j)*columns+i])
                    if score > heighestScore {
                        heighestScore = score
                        classIndex = j
                    }
                }
                return (classIndex, heighestScore)
            }()
            
            let maskCoefficients = {
                var coefficients: [Float] = []
                for k in 0..<32 {
                    coefficients.append(Float(truncating: output[(4+numberOfClasses+k)*columns+i]))
                }
                return coefficients
            }()
            
            // Convert box from xywh to xyxy
            let left = centerX - width/2
            let top = centerY - height/2
            let right = centerX + width/2
            let bottom = centerY + height/2
            
            let prediction = Prediction(
                classIndex: classIndex,
                score: score,
                xyxy: (left, top, right, bottom),
                maskCoefficients: maskCoefficients,
                inputImgSize: inputImgSize
            )
            predictions.append(prediction)
        }
        
        return predictions
    }
    
    func nonMaximumSuppression(
        predictions: [Prediction],
        iouThreshold: Float,
        limit: Int
    ) -> [Prediction] {
        guard !predictions.isEmpty else {
            return []
        }
        
        let sortedIndices = predictions.indices.sorted {
            predictions[$0].score > predictions[$1].score
        }
        
        var selected: [Prediction] = []
        var active = [Bool](repeating: true, count: predictions.count)
        var numActive = active.count

        // The algorithm is simple: Start with the box that has the highest score.
        // Remove any remaining boxes that overlap it more than the given threshold
        // amount. If there are any boxes left (i.e. these did not overlap with any
        // previous boxes), then repeat this procedure, until no more boxes remain
        // or the limit has been reached.
        outer: for i in 0..<predictions.count {
            
            if active[i] {
                
                let boxA = predictions[sortedIndices[i]]
                selected.append(boxA)
                
                if selected.count >= limit { break }

                for j in i+1..<predictions.count {
                
                    if active[j] {
                
                        let boxB = predictions[sortedIndices[j]]
                        
                        if IOU(a: boxA.xyxy, b: boxB.xyxy) > iouThreshold {
                            
                            active[j] = false
                            numActive -= 1
                           
                            if numActive <= 0 { break outer }
                        
                        }
                    
                    }
                
                }
            }
            
        }
        return selected
    }
    
    
    func IOU(a: XYXY, b: XYXY) -> Float {
        // Calculate the intersection coordinates
        let x1 = max(a.x1, b.x1)
        let y1 = max(a.y1, b.y1)
        let x2 = max(a.x2, b.x2)
        let y2 = max(a.y1, b.y2)
        
        // Calculate the intersection area
        let intersection = max(x2 - x1, 0) * max(y2 - y1, 0)
        
        // Calculate the union area
        let area1 = (a.x2 - a.x1) * (a.y2 - a.y1)
        let area2 = (b.x2 - b.x1) * (b.y2 - b.y1)
        let union = area1 + area2 - intersection
        
        // Calculate the IoU score
        let iou = intersection / union
        
        return iou
    }
    
    func getMaskProtosFromOutput(
        output: MLMultiArray,
        rows: Int,
        columns: Int,
        tubes: Int
    ) -> [[UInt8]] {
        var masks: [[UInt8]] = []
        for tube in 0..<tubes {
            var mask: [UInt8] = []
            for i in 0..<(rows*columns) {
                let index = tube*(rows*columns)+i
                mask.append(UInt8(truncating: output[index]))
            }
            masks.append(mask)
        }
        return masks
    }
    
    func masksFromProtos(
        boxPredictions: [Prediction],
        maskProtos: [[UInt8]],
        maskSize: (width: Int, height: Int),
        originalImgSize: CGSize
    ) -> [MaskPrediction] {
        NSLog("Generate masks from prototypes")
        var maskPredictions: [MaskPrediction] = []
        for prediction in boxPredictions {
            
            let maskCoefficients = prediction.maskCoefficients
            
            var finalMask: [Float] = []
            
            for (index, maskProto) in maskProtos.enumerated() {
                let weight = maskCoefficients[index]
                finalMask = finalMask.add(maskProto.map { Float($0) * weight })
            }
            
            NSLog("Apply sigmoid")
            finalMask = finalMask.map { sigmoid(value: $0) }
            
            NSLog("Crop mask to bounding box")
            let croppedMask = crop(
                mask: finalMask,
                maskSize: maskSize,
                box: prediction.xyxy)

            
            let scale = min(
                max(
                    Int(originalImgSize.width) / maskSize.width,
                    Int(originalImgSize.height) / maskSize.height),
                6)
            
            
            let targetSize = (
                width: maskSize.width * scale,
                height: maskSize.height * scale)
            
            NSLog("Upsample mask with size \(maskSize) to \(targetSize)")
            let upsampledMask = croppedMask
                .map { Float(($0 > maskThreshold ? 1 : 0)) }
                .upsample(
                    initialSize: maskSize,
                    scale: scale
                )
                .map { UInt8(($0 > maskThreshold ? 1 : 0) * 255) }
            
            maskPredictions.append(
                MaskPrediction(
                    classIndex: prediction.classIndex,
                    mask: upsampledMask,
                    maskSize: targetSize))
        }
        
        return maskPredictions
    }

    func sigmoid(value: Float) -> Float {
        return 1.0 / (1.0 + exp(-value))
    }
    
    func crop(
        mask: [Float],
        maskSize: (width: Int, height: Int),
        box: XYXY
    ) -> [Float] {
        let rows = maskSize.height
        let columns = maskSize.width
        
        let x1 = Int(box.x1 / 4)
        let y1 = Int(box.y1 / 4)
        let x2 = Int(box.x2 / 4)
        let y2 = Int(box.y2 / 4)
        
        var croppedArr: [Float] = []
        for row in 0..<rows {
            for column in 0..<columns {
                if column >= x1 && column <= x2 && row >= y1 && row <= y2 {
                    croppedArr.append(mask[row*columns+column])
                } else {
                    croppedArr.append(0)
                }
            }
        }
        return croppedArr
    }
}


