//
//  ImagePicker.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/12/23.
//
#if os(iOS)
import SwiftUI
import UIKit
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
	@Binding var imageData: Data
	@Binding var useOriginalImage: Bool
	@Binding var loading: Bool

	func makeUIViewController(context: Context) -> PHPickerViewController {
		var config = PHPickerConfiguration()
		config.filter = .images
		let picker = PHPickerViewController(configuration: config)
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		let parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}

		func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
			picker.dismiss(animated: true)

			guard let provider = results.first?.itemProvider else { return }
			self.parent.loading = true

			if provider.canLoadObject(ofClass: UIImage.self) {
				provider.loadObject(ofClass: UIImage.self) { imageData, _ in
					if let imageData = imageData as? UIImage {
						imageData.jpegData(compressionQuality: 0.2)
						var rightSideUpImage = imageData
						if (imageData.imageOrientation != UIImage.Orientation.up) {
							

						  UIGraphicsBeginImageContextWithOptions(imageData.size, false, imageData.scale);
						  let rectangle = CGRect(x: 0, y: 0, width: imageData.size.width, height: imageData.size.height)
							imageData.draw(in: rectangle)

							rightSideUpImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
						  UIGraphicsEndImageContext();

						}
						DispatchQueue.main.async {
							self.parent.loading = false
							self.parent.imageData = rightSideUpImage.jpegData(compressionQuality: 0.2) ?? Data()
							self.parent.useOriginalImage = false
						}
						
					}
				}
			}
		}
	}
}
#endif
