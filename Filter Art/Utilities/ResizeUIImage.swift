//
//  ResizeUIImage.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/28/24.
//

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
func resizeUIImage(image: UIImage, width: Double = 1000.0, height: Double = 1000.0) -> UIImage {
		var originalWidth = width
		var originalHeight = height
		var newWidth = width
		var newHeight = height
		originalWidth = image.size.width
		originalHeight = image.size.height
		if originalWidth >= originalHeight && originalWidth >= width {
			let scaleFactor = width/originalWidth
			newWidth =  originalWidth * scaleFactor
			newHeight = originalHeight * scaleFactor
		} else if originalHeight >= originalWidth && originalHeight >= height {
			let scaleFactor = height/originalHeight
			newWidth =  originalWidth * scaleFactor
			newHeight = originalHeight * scaleFactor
		} else {
			newWidth = originalWidth
			newHeight = originalHeight
		}
		let newSize = CGSize(width: newWidth, height: newHeight)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()
		return newImage
	}
#endif
