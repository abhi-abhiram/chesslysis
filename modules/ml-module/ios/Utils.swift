//
//  Utils.swift
//  MlModule
//
//  Created by Anukoola abhiram on 13/04/24.
//

import Foundation



class Utils {
    
    static func areaQuad(points:[CGPoint])->CGFloat{
        
        let p1 = points[0]
        let p2 = points[1]
        let p3 = points[2]
        let p4 = points[3]
        
        return  0.5 * (
            (p1.x*p2.y + p2.x*p3.y + p3.x*p4.y + p4.x*p1.y) -
            (p2.x*p1.y + p3.x*p2.y + p4.x*p3.y + p1.x*p4.y)
        )
    }

    static func convertNormalizedToCartesian(normalizedPoint: CGPoint, viewSize: CGSize) -> CGPoint {
        let x = normalizedPoint.x * viewSize.width
        let y = normalizedPoint.y * viewSize.height
        return CGPoint(x: x, y: y)
    }
    
    static func convertToGrayScale(image: UIImage) throws -> UIImage? {
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard let cgImg = image.cgImage else {
            throw ImageLoadError.CGImageNotFound
        }
        
        context?.draw(cgImg, in: imageRect)
        
        if let makeImg = context?.makeImage() {
            let imageRef = makeImg
            let newImage = UIImage(cgImage: imageRef)
            return newImage
        }
        
        return nil
    }
    
    static func perspectiveCorrection(inputImage: CIImage, points: [CGPoint]) -> CIImage {
        let perspectiveCorrectionFilter = CIFilter.perspectiveCorrection()
        perspectiveCorrectionFilter.inputImage = inputImage
        perspectiveCorrectionFilter.bottomLeft = points[0]
        perspectiveCorrectionFilter.bottomRight = points[1]
        perspectiveCorrectionFilter.topRight = points[2]
        perspectiveCorrectionFilter.topLeft = points[3]
        return perspectiveCorrectionFilter.outputImage!
    }

    
    static func drawContours(path:CGPath, sourceImage: CGImage) -> UIImage {
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
    
    static func addPaddingToImg(for img:UIImage, padding: Int)-> CGImage?{
        let paddingWidth = padding
        let paddingHeight = padding
        
        let cgImage = img.cgImage!
        
        let newWidth = cgImage.width + paddingWidth * 2
        let newHeight = cgImage.height + paddingHeight * 2
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        let newContext = CGContext(data: nil, width: Int(newWidth), height: Int(newHeight), bitsPerComponent: 8, bytesPerRow:0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: bitmapInfo.rawValue)
        
        let rect = CGRect(x: 0, y: 0, width: Int(newWidth), height: Int(newHeight))
        newContext?.setFillColor(gray: 0.5, alpha: 1.0)
        newContext?.addRect(rect)
        newContext?.drawPath(using: .fill)
        newContext?.fill(rect)
        
        newContext?.translateBy(x: CGFloat(paddingWidth), y: CGFloat(paddingHeight))
        newContext?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        
        return newContext?.makeImage()
    }
}



