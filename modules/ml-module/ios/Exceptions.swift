// Copyright 2021-present 650 Industries. All rights reserved.

import CoreGraphics
import ExpoModulesCore

internal class ModelLoadFailedException:Exception {
    override var reason: String {
        "Failed to load model"
    }
}

internal class ImageNotFoundException:Exception {
    override var reason: String {
        "Image is not Found"
    }
}

enum ImageLoadError:Error {
    case NotFound
    case LoadingFailed
    case CGImageNotFound
}

enum PredictError:Error {
    case FileSystemNotFound
}

internal class GrayScaleConversionException:Exception{
    override var reason: String {
        "Failed to convert image to grayscale"
    }
}
