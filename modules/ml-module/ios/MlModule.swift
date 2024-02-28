//
//  MLModule.swift
//  MlModule
//
//  Created by Anukoola abhiram on 27/02/24.
import ExpoModulesCore
import CoreML
import Vision

let DETECTION_COMPLETED_EVENT_NAME = "onDetectionComplete"


struct FileReadOptions: Record {
    @Field
    var test:Int = 0
}



public class MlModule: Module {
    
    var image:UIImage?
    var model: VNCoreMLModel?
    
    public func definition() -> ModuleDefinition {
        Name("MlModule")
        Events(DETECTION_COMPLETED_EVENT_NAME)
        
        OnCreate {
            if #available(iOS 15.0, *) {
                do {
                    let yoloobj = try Chesspieces()
                    self.model = try VNCoreMLModel(for: yoloobj.model)
                }catch {
                    print("Error initializing model")
                }
            } else {
                
            }
        }
        
        
        Function("predict") {
            (name:FileReadOptions) in
            return name.test
        }
   
        Function("details"){
            return model?.inputImageFeatureName ?? "No Model"
        }
    }
}
