//
//  MainImage.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct MainImage: View {
	@Binding var loading: Bool
	@Binding var renderedImage: Image
	@EnvironmentObject var imageDataStore: ImageDataStore
	@AppStorage(AppStorageKeys.imageInvertColors.rawValue) private var invertColors: Bool = false
	@AppStorage(AppStorageKeys.imageHueRotation.rawValue) private var hueRotation: Double = 0
	@AppStorage(AppStorageKeys.imageUseHueRotation.rawValue) private var useHueRotation: Bool = true
	@AppStorage(AppStorageKeys.imageContrast.rawValue) private var contrast: Double = 1
	@AppStorage(AppStorageKeys.imageUseContrast.rawValue) private var useContrast: Bool = true
	@AppStorage(AppStorageKeys.imageUseColorMultiply.rawValue) private var useColorMultiply: Bool = true
	@AppStorage(AppStorageKeys.imageColorMultiplyColor.rawValue) private var colorMultiplyColor: Color = Color.white
	@AppStorage(AppStorageKeys.imageUseSaturation.rawValue) private var useSaturation: Bool = true
	@AppStorage(AppStorageKeys.imageSaturation.rawValue) private var saturation: Double = 1
	@AppStorage(AppStorageKeys.imageUseBrightness.rawValue) private var useBrightness: Bool = true
	@AppStorage(AppStorageKeys.imageBrightness.rawValue) private var brightness: Double = 0
	@AppStorage(AppStorageKeys.imageUseGrayscale.rawValue) private var useGrayscale: Bool = true
	@AppStorage(AppStorageKeys.imageGrayscale.rawValue) private var grayscale: Double = 0
	@AppStorage(AppStorageKeys.imageUseOpacity.rawValue) private var useOpacity: Bool = true
	@AppStorage(AppStorageKeys.imageOpacity.rawValue) private var opacity: Double = 1
	@AppStorage(AppStorageKeys.imageUseBlur.rawValue) private var useBlur: Bool = true
	@AppStorage(AppStorageKeys.imageBlur.rawValue) private var blur: Double = 0
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
    var body: some View {
		Group {
			if loading {
				VStack {
					Text("Loading Image…")
					ProgressView().controlSize(.large)
				}
			} else {
				Group {
					renderedImage.resizable().aspectRatio(contentMode: .fit)
				}
#if os(macOS)
				.onDrag {
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "M-d-y h.mm a"
					let dateString = dateFormatter.string(from: Date())
					let filename = "Image \(dateString).png"
					let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
					guard let tiffRepresentation = getFilteredImage(forSharing: true).tiffRepresentation else {
						return NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					}
					let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
					guard let bitmapRepresentation = bitmapImage?.representation(using: .png, properties: [:]) else {
						return NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					}
					
					try? bitmapRepresentation.write(to: url)
					
					let provider = NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: UTType.fileURL.identifier)
					provider.suggestedName = filename
					return provider
				}
#endif
			}
		}
    }
	
#if os(iOS)
	@MainActor func getFilteredImage(forSharing: Bool = false) -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let uiImage = (UIImage(data: imageDataStore.imageData)  ?? UIImage())
			originalWidth = uiImage.size.width
			originalHeight = uiImage.size.height
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
		}
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		})
			.if(useHueRotation, transform: { view in
				view.hueRotation(.degrees(hueRotation))
			}).if(useContrast, transform: { view in
				view.contrast(contrast)
			}).if(invertColors, transform: { view in
				view.colorInvert()
			}).if(useColorMultiply, transform: { view in
				view.colorMultiply(colorMultiplyColor)
			}).if(useSaturation, transform: { view in
				view.saturation(saturation)
			}).if(useBrightness, transform: { view in
				view.brightness(brightness)
			}).if(useGrayscale, transform: { view in
				view.grayscale(grayscale)
			}).if(useOpacity, transform: { view in
				view.opacity(opacity)
			}).if(useBlur) { view in
				view.blur(radius: blur)
			})
		
		if let uiImage = renderer.uiImage {
			print("01/22/2024 success")
			return uiImage
		}
		return UIImage(named: "FallColors") ?? UIImage()
	}
#else
	@MainActor func getFilteredImage(forSharing: Bool = false) -> NSImage{
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let nsImage = (NSImage(data: imageDataStore.imageData)  ?? NSImage())
			originalWidth = nsImage.size.width
			originalHeight = nsImage.size.height
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
		}
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		}).if(useHueRotation, transform: { view in
			view.hueRotation(.degrees(hueRotation))
		}).if(useContrast, transform: { view in
			view.contrast(contrast)
		}).if(invertColors, transform: { view in
			view.colorInvert()
		}).if(useColorMultiply, transform: { view in
			view.colorMultiply(colorMultiplyColor)
		}).if(useSaturation, transform: { view in
			view.saturation(saturation)
		}).if(useBrightness, transform: { view in
			view.brightness(brightness)
		}).if(useGrayscale, transform: { view in
			view.grayscale(grayscale)
		}).if(useOpacity, transform: { view in
			view.opacity(opacity)
		}).if(useBlur) { view in
			view.blur(radius: blur)
		})
		if let nsImage = renderer.nsImage {
			return  nsImage
		}
		return NSImage(named: "FallColors") ?? NSImage()
	}
#endif
	
	func getImage() -> Image {
		if useOriginalImage {
			return Image("FallColors")
		} else {
#if os(macOS)
			return Image(nsImage: (NSImage(data: imageDataStore.imageData) ?? NSImage()))
#else
			return Image(uiImage: (UIImage(data: imageDataStore.imageData)  ?? UIImage()))
#endif
		}
	}
}

/*
#Preview {
    MainImage()
}
*/
