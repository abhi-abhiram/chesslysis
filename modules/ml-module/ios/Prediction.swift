//
//  Prediction.swift
//  MlModule
//
//  Created by Anukoola abhiram on 25/03/24.
//

import Foundation

typealias XYXY = (x1: Float, y1: Float, x2: Float, y2: Float)

// MARK: Prediction
internal struct Prediction {

    let classIndex: Int
    let score: Float
    let xyxy: XYXY
    let maskCoefficients: [Float]
    
    let inputImgSize: CGSize
}
