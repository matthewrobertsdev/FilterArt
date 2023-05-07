//
//  ImageSaver.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/14/23.
//

#if os(iOS)
import UIKit
import SwiftUI

class ImageSaver: NSObject {
	@Binding var showingSuccessAlert: Bool
	@Binding var showingErrorAlert: Bool
	init(showingSuccessAlert: Binding<Bool>, showingErrorAlert: Binding<Bool>) {
		self._showingSuccessAlert = showingSuccessAlert
		self._showingErrorAlert = showingErrorAlert
	}
	func writeToPhotoAlbum(image: UIImage) {
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
	}

	@objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let _ = error {
			showingErrorAlert = true
		} else {
			showingSuccessAlert = true
		}
	}
}
#endif
