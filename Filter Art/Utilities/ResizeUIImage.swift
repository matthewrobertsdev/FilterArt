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
	func resizeUIImage(image: UIImage) -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		originalWidth = image.size.width
		originalHeight = image.size.height
		if originalWidth >= originalHeight && originalWidth >= 1000.0 {
			let scaleFactor = 1000.0/originalWidth
			desiredWidth =  originalWidth * scaleFactor
			desiredHeight = originalHeight * scaleFactor
		} else if originalHeight >= originalWidth && originalHeight >= 1000.0 {
			let scaleFactor = 1000.0/originalHeight
			desiredWidth =  originalWidth * scaleFactor
			desiredHeight = originalHeight * scaleFactor
		} else {
			desiredWidth = originalWidth
			desiredHeight = originalHeight
		}
		let newSize = CGSize(width: desiredWidth, height: desiredHeight)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()
		return newImage
	}
#endif
