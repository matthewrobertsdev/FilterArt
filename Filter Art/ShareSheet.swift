//
//  SharingSheet.swift
//  Contact Cards (iOS)
//
//  Created by Matt Roberts on 3/18/22.
//
#if os(iOS)
import SwiftUI
import UIKit
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
	var imageData : UIImage
	var applicationActivities: [UIActivity]? = nil
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: [context.coordinator], applicationActivities: applicationActivities)
		controller.modalPresentationStyle = .automatic
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
	
	func makeCoordinator() -> ShareSheet.Coordinator {
		Coordinator(self.imageData)
	}
	
	class Coordinator : NSObject, UIActivityItemSource {
		private let imageData: UIImage
		
		init(_ imageData: UIImage) {
			self.imageData = imageData
			super.init()
		}
		
		func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
			return UIImage()
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
			return imageData
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
			return "Share your image."
		}
		
		func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
			
			let metadata = LPLinkMetadata()
			
			// share sheet preview title
			metadata.title = "Share your image."
			// share sheet preview icon
			let imageProvider = NSItemProvider(object: imageData)
			metadata.imageProvider = imageProvider
			metadata.iconProvider = imageProvider
			return metadata
		}
	}
}
#endif
