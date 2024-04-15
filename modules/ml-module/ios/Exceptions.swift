// Copyright 2021-present 650 Industries. All rights reserved.

import CoreGraphics
import ExpoModulesCore

enum ImageLoadError:Error {
    case NotFound
    case LoadingFailed
    case CGImageNotFound
    case FailedToConvertGrayScale
    case FailedToConvertCIImage
}

enum PredictError:Error {
    case FileSystemNotFound
}

enum DetectionError:Error {
    case FailedToLoadBoardSegModel
    case FailedToDetectBoard
    case FailedToLoadPiecesObjModel
    case FailedToDetectPieces
}
