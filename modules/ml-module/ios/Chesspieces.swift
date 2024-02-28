//
//  ChessboardSeg.swift
//  MlModule
//
//  Created by Anukoola abhiram on 28/02/24.

import Foundation
import CoreML


/// Model Prediction Input Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class ChesspiecesInput : MLFeatureProvider {

    /// image as color (kCVPixelFormatType_32BGRA) image buffer, 640 pixels wide by 640 pixels high
    var image: CVPixelBuffer

    var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    init(image: CVPixelBuffer) {
        self.image = image
    }

    convenience init(imageWith image: CGImage) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    convenience init(imageAt image: URL) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 640, pixelsHigh: 640, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class ChesspiecesOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// var_1019 as 1 × 3 × 80 × 80 × 17 5-dimensional array of floats
    var var_1019: MLMultiArray {
        return self.provider.featureValue(for: "var_1019")!.multiArrayValue!
    }

    /// var_1019 as 1 × 3 × 80 × 80 × 17 5-dimensional array of floats
    var var_1019ShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.var_1019)
    }

    /// var_1034 as 1 × 3 × 40 × 40 × 17 5-dimensional array of floats
    var var_1034: MLMultiArray {
        return self.provider.featureValue(for: "var_1034")!.multiArrayValue!
    }

    /// var_1034 as 1 × 3 × 40 × 40 × 17 5-dimensional array of floats
    var var_1034ShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.var_1034)
    }

    /// var_1049 as 1 × 3 × 20 × 20 × 17 5-dimensional array of floats
    var var_1049: MLMultiArray {
        return self.provider.featureValue(for: "var_1049")!.multiArrayValue!
    }

    /// var_1049 as 1 × 3 × 20 × 20 × 17 5-dimensional array of floats
    var var_1049ShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.var_1049)
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(var_1019: MLMultiArray, var_1034: MLMultiArray, var_1049: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["var_1019" : MLFeatureValue(multiArray: var_1019), "var_1034" : MLFeatureValue(multiArray: var_1034), "var_1049" : MLFeatureValue(multiArray: var_1049)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class Chesspieces {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "ChesspiecesDet", withExtension:"mlmodelc")!
    }

    /**
        Construct ChesspiecesDet instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of ChesspiecesDet.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `ChesspiecesDet.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct ChesspiecesDet instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct ChesspiecesDet instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Chesspieces, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct ChesspiecesDet instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Chesspieces {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct ChesspiecesDet instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<Chesspieces, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(Chesspieces(model: model)))
            }
        }
    }

    /**
        Construct ChesspiecesDet instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> Chesspieces {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return Chesspieces(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as ChesspiecesDetInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as ChesspiecesDetOutput
    */
    func prediction(input: ChesspiecesInput) throws -> ChesspiecesOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as ChesspiecesDetInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as ChesspiecesDetOutput
    */
    func prediction(input: ChesspiecesInput, options: MLPredictionOptions) throws -> ChesspiecesOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return ChesspiecesOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        - parameters:
           - input: the input to the prediction as ChesspiecesDetInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as ChesspiecesDetOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    func prediction(input: ChesspiecesInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> ChesspiecesOutput {
        let outFeatures = try await model.prediction(from: input, options:options)
        return ChesspiecesOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - image as color (kCVPixelFormatType_32BGRA) image buffer, 640 pixels wide by 640 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as ChesspiecesDetOutput
    */
    func prediction(image: CVPixelBuffer) throws -> ChesspiecesOutput {
        let input_ = ChesspiecesInput(image: image)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [ChesspiecesDetInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [ChesspiecesDetOutput]
    */
    func predictions(inputs: [ChesspiecesInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [ChesspiecesOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [ChesspiecesOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  ChesspiecesOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
