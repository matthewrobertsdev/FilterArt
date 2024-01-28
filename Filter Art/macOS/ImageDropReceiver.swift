//
//  ImageDropReceiver.swift
//  Filter Art
//
//  Created by Matt Roberts on 4/9/23.
//

#if os(macOS)
import SwiftUI

protocol DestinationViewDelegate {
	func processImageURLs(_ urls: [URL])
	func processImage(_ image: NSImage)
	func processAction(_ action: String)
}

struct ImageDropReceiver: NSViewRepresentable {
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@EnvironmentObject var imageDataStore: ImageViewModel
	
	var acceptableTypes: Set<NSPasteboard.PasteboardType> { return [.png, .tiff, .URL, .fileURL] }
	
	class Coordinator: NSObject, DestinationViewDelegate {
		func processImageURLs(_ urls: [URL]) {
			for (_,url) in urls.enumerated() {
				
				if let image = NSImage(contentsOf:url) {
					
					processImage(image)
				}
			}
		}
		
		func processImage(_ image: NSImage) {
			DispatchQueue.global(qos: .userInitiated).async {
				if let imageData = image.tiffRepresentation {
					var originalWidth = 1000.0
					var originalHeight = 1000.0
					var desiredWidth = 1000.0
					var desiredHeight = 1000.0
					if let fullSizeImage = NSImage(data: imageData) {
						originalWidth = fullSizeImage.size.width
						originalHeight = fullSizeImage.size.height
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
						let destSize = NSMakeSize(desiredWidth, desiredHeight)
						let newImage = NSImage(size: destSize)
						newImage.lockFocus()
						fullSizeImage.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, fullSizeImage.size.width, fullSizeImage.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
						newImage.unlockFocus()
						newImage.size = destSize
						if let newImageData = newImage.tiffRepresentation {
							DispatchQueue.main.async { [weak self] in
								guard let self = self else {
									return
								}
								self.imageDropReceiver.imageDataStore.imageData = newImageData
								self.imageDropReceiver.useOriginalImage = false
								self.imageDropReceiver.imageDataStore.waitingForDrop = false
							}
						}
					}
				}
			}
		}
		
		func processAction(_ action: String) {
			
		}
		
		var imageDropReceiver: ImageDropReceiver
		
		init(_ imageDropReceiver: ImageDropReceiver) {
			self.imageDropReceiver = imageDropReceiver
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeNSView(context: Context) -> NSImageDropReceiver {
		let nsImageDropReceiver = NSImageDropReceiver()
		nsImageDropReceiver.registerForDraggedTypes(Array(acceptableTypes))
		nsImageDropReceiver.delegate = context.coordinator
		return nsImageDropReceiver
	}
	
	func updateNSView(_ nsView: NSImageDropReceiver, context: Context) {
		
	}
	
	typealias NSViewType = NSImageDropReceiver
	
	
}

/*
 struct ImageDropReceiver_Previews: PreviewProvider {
 static var previews: some View {
 ImageDropReceiver()
 }
 }
 */
#endif
