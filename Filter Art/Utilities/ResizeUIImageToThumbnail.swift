//
//  ResizeUIImageToThumbnail.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/28/24.
//

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
func resizeUIImageToThumbnail(image: UIImage) -> UIImage {
	return resizeUIImage(image: image, width: 200.0, height: 200.0)
}
#endif
