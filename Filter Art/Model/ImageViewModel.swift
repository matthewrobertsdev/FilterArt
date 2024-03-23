//
//  ImageStore.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/13/22.
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers
#endif

@MainActor 
class ImageViewModel: ObservableObject {
	
	private var defaults = UserDefaults.standard
	
	@Published var renderedImage = Image(uiImage: UIImage())
	@Published var thumbnailImage = Image(uiImage: UIImage())
	
	@Published var imageData: Data = Data()
	
	@Published var waitingForDrop = false
	
	@Published var forUndo = [FilterModel]()
	@Published var forRedo = [FilterModel]()
	@Published var isModifying = false
	
	@Published var useOriginalImage = true {
		didSet {
			defaults.setValue(useOriginalImage, forKey: AppStorageKeys.imageUseOriginalImage.rawValue)
		}
	}
	@Published var invertColors = false {
		didSet {
			defaults.setValue(invertColors, forKey: AppStorageKeys.imageInvertColors.rawValue)
		}
	}
	@Published var useHueRotation = true {
		didSet {
			defaults.setValue(useHueRotation, forKey: AppStorageKeys.imageUseHueRotation.rawValue)
		}
	}
	@Published var hueRotation = 0.0 {
		didSet {
			defaults.setValue(hueRotation, forKey: AppStorageKeys.imageHueRotation.rawValue)
		}
	}
	@Published var useContrast = true {
		didSet {
			defaults.setValue(useContrast, forKey: AppStorageKeys.imageUseContrast.rawValue)
		}
	}
	@Published var contrast = 1.0 {
		didSet {
			defaults.setValue(contrast, forKey: AppStorageKeys.imageContrast.rawValue)
		}
	}
	@Published var useColorMultiply = true {
		didSet {
			defaults.setValue(useColorMultiply, forKey: AppStorageKeys.imageUseColorMultiply.rawValue)
		}
	}
	@Published var colorMultiplyColor = Color.white {
		didSet {
			defaults.setValue(colorMultiplyColor.rawValue, forKey: AppStorageKeys.imageColorMultiplyColor.rawValue)
		}
	}
	@Published var useSaturation = true {
		didSet {
			defaults.setValue(useSaturation, forKey: AppStorageKeys.imageUseSaturation.rawValue)
		}
	}
	@Published var saturation = 1.0 {
		didSet {
			defaults.setValue(saturation, forKey: AppStorageKeys.imageSaturation.rawValue)
		}
	}
	@Published var useBrightness = true {
		didSet {
			defaults.setValue(useBrightness, forKey: AppStorageKeys.imageUseBrightness.rawValue)
		}
	}
	@Published var brightness = 0.0 {
		didSet {
			defaults.setValue(brightness, forKey: AppStorageKeys.imageBrightness.rawValue)
		}
	}
	@Published var useGrayscale = true {
		didSet {
			defaults.setValue(useGrayscale, forKey: AppStorageKeys.imageUseGrayscale.rawValue)
		}
	}
	@Published var grayscale = 0.0 {
		didSet {
			defaults.setValue(grayscale, forKey: AppStorageKeys.imageGrayscale.rawValue)
		}
	}
	@Published var useOpacity = true {
		didSet {
			defaults.setValue(useOpacity, forKey: AppStorageKeys.imageUseOpacity.rawValue)
		}
	}
	@Published var opacity = 1.0 {
		didSet {
			defaults.setValue(opacity, forKey: AppStorageKeys.imageOpacity.rawValue)
		}
	}
	@Published var useBlur = true {
		didSet {
			defaults.setValue(useBlur, forKey: AppStorageKeys.imageUseBlur.rawValue)
		}
	}
	@Published var blur = 0.0 {
		didSet {
			defaults.setValue(blur, forKey: AppStorageKeys.imageBlur.rawValue)
		}
	}
	
	init() {
		UserDefaults.standard.register(defaults: [
			AppStorageKeys.imageUseOriginalImage.rawValue: true,
			AppStorageKeys.imageInvertColors.rawValue: false,
			AppStorageKeys.imageUseHueRotation.rawValue: true,
			AppStorageKeys.imageHueRotation.rawValue: 0.0,
			AppStorageKeys.imageUseContrast.rawValue: true,
			AppStorageKeys.imageContrast.rawValue: 1.0,
			AppStorageKeys.imageUseColorMultiply.rawValue: true,
			AppStorageKeys.imageColorMultiplyColor.rawValue: Color.white.rawValue,
			AppStorageKeys.imageUseSaturation.rawValue: true,
			AppStorageKeys.imageSaturation.rawValue: 1.0,
			AppStorageKeys.imageUseBrightness.rawValue: true,
			AppStorageKeys.imageBrightness.rawValue: 0.0,
			AppStorageKeys.imageUseGrayscale.rawValue: true,
			AppStorageKeys.imageGrayscale.rawValue: 0.0,
			AppStorageKeys.imageUseOpacity.rawValue: true,
			AppStorageKeys.imageOpacity.rawValue: 1.0,
			AppStorageKeys.imageUseBlur.rawValue: true,
			AppStorageKeys.imageBlur.rawValue: 0.0,
		])
		useOriginalImage = defaults.bool(forKey: AppStorageKeys.imageUseOriginalImage.rawValue)
		invertColors = defaults.bool(forKey: AppStorageKeys.imageInvertColors.rawValue)
		useHueRotation = defaults.bool(forKey: AppStorageKeys.imageUseHueRotation.rawValue)
		hueRotation = defaults.double(forKey: AppStorageKeys.imageHueRotation.rawValue)
		useContrast = defaults.bool(forKey: AppStorageKeys.imageUseContrast.rawValue)
		contrast = defaults.double(forKey: AppStorageKeys.imageContrast.rawValue)
		useColorMultiply = defaults.bool(forKey: AppStorageKeys.imageUseColorMultiply.rawValue)
		if let colorMultiplyColorString = defaults.string(forKey: AppStorageKeys.imageColorMultiplyColor.rawValue) {
			colorMultiplyColor = Color(rawValue: colorMultiplyColorString) ?? Color.white
		}
		useSaturation = defaults.bool(forKey: AppStorageKeys.imageUseSaturation.rawValue)
		saturation = defaults.double(forKey: AppStorageKeys.imageSaturation.rawValue)
		useBrightness = defaults.bool(forKey: AppStorageKeys.imageUseBrightness.rawValue)
		brightness = defaults.double(forKey: AppStorageKeys.imageBrightness.rawValue)
		useGrayscale = defaults.bool(forKey: AppStorageKeys.imageUseGrayscale.rawValue)
		grayscale = defaults.double(forKey: AppStorageKeys.imageGrayscale.rawValue)
		useOpacity = defaults.bool(forKey: AppStorageKeys.imageUseOpacity.rawValue)
		opacity = defaults.double(forKey: AppStorageKeys.imageOpacity.rawValue)
		useBlur = defaults.bool(forKey: AppStorageKeys.imageUseBlur.rawValue)
		blur = defaults.double(forKey: AppStorageKeys.imageBlur.rawValue)
	}
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: false)
		.appendingPathComponent("image.data")
	}
	
	static func exportURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: false)
		.appendingPathComponent("Filter Art.png")
	}
	
	static func load(completion: @escaping (Result<Data, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let fileURL = try fileURL()
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					Task { @MainActor in
						completion(.success(Data()))
					}
					return
				}
				Task { @MainActor in
					completion(.success(file.availableData
									   ))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
	
	static func save(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let outfile = try fileURL()
				try imageData.write(to: outfile)
				Task { @MainActor in
					completion(.success(1))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
	
	static func saveForExport(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let outfile = try exportURL()
				try imageData.write(to: outfile)
				Task { @MainActor in
					completion(.success(1))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
#if os(iOS)
	@MainActor func getFilteredImage() -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let uiImage = (UIImage(data: imageData)  ?? UIImage())
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
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).frame(width: desiredWidth, height: desiredHeight)
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
			return uiImage
		}
		return UIImage(named: "FallColors") ?? UIImage()
	}
#else
	@MainActor func getFilteredImage() -> NSImage{
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let nsImage = (NSImage(data: imageData)  ?? NSImage())
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
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).frame(width: desiredWidth, height: desiredHeight).if(useHueRotation, transform: { view in
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
			return Image(nsImage: (NSImage(data: imageData) ?? NSImage()))
#else
			return Image(uiImage: (UIImage(data: imageData)  ?? UIImage()))
#endif
		}
	}
	func getThumbnailImage() -> Image {
		if useOriginalImage {
			return Image("FallColors")
		} else {
#if os(macOS)
			return Image(nsImage: (NSImage(data: imageData) ?? NSImage()))
#else
			return thumbnailImage
#endif
		}
	}
#if os(macOS)
	@MainActor func getImageNSItemProvider() -> NSItemProvider {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M-d-y h.mm a"
		let dateString = dateFormatter.string(from: Date())
		let filename = "Image \(dateString).png"
		let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
		guard let tiffRepresentation = getFilteredImage().tiffRepresentation else {
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
	
	func undo() -> FilterModel? {
		isModifying = true
		if forUndo.count > 0 {
			let filterState = forUndo.popLast()
			if let filterState = filterState {
				forRedo.append(filterState)
			}
		}
		return forUndo.last
	}
	
	func redo() -> FilterModel? {
		isModifying = true
		let filterState = forRedo.popLast()
		if let filterState = filterState {
			forUndo.append(filterState)
		}
		return filterState
	}
	
	var canUndo: Bool {
		forUndo.count > 1
	}
	
	var canRedo: Bool {
		forRedo.count > 0
	}
	
	func storeSnapshot() {
		forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		forRedo = [FilterModel]()
	}
	
	func handleUndo() {
		assignFilterModelToAppStorage(filter: undo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			isModifying = false
		}
	}
	func handleRedo() {
		assignFilterModelToAppStorage(filter: redo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			isModifying = false
		}
	}
	
	func resetAll() {
		assignFilterModelToAppStorage(filter: originalFilter)
	}
	
	func shouldDisableResetAll() -> Bool {
		return blur == originalFilter.blur && brightness == originalFilter.brightness
		&& abs(colorMultiplyColor.components.red - originalFilter.colorMultiplyR) < 0.02
		&& abs(colorMultiplyColor.components.blue - originalFilter.colorMultiplyB) < 0.02
		&& abs(colorMultiplyColor.components.green - originalFilter.colorMultiplyG) < 0.02
		&& abs(colorMultiplyColor.components.opacity - originalFilter.colorMultiplyO) < 0.02
		&& contrast == originalFilter.contrast && grayscale == originalFilter.grayscale
		&& hueRotation == originalFilter.hueRotation && invertColors == originalFilter.invertColors
		&& opacity == originalFilter.opacity && saturation == originalFilter.saturation
		&& useBlur == originalFilter.useBlur && useBrightness == originalFilter.useBrightness
		&& useColorMultiply == originalFilter.useColorMultiply
		&& useContrast == originalFilter.useContrast
		&& useGrayscale == originalFilter.useGrayscale
		&& useHueRotation == originalFilter.useHueRotation
		&& useOpacity == originalFilter.useOpacity
		&& useSaturation == originalFilter.useSaturation
	}
	
	func asignSavedFilterComponentsToAppStorage(selectedSavedFilter: Filter?) {
		if let filter = selectedSavedFilter {
			invertColors = filter.invertColors
			useHueRotation = filter.useHueRotation
			hueRotation = filter.hueRotation
			useContrast = filter.useContrast
			contrast = filter.contrast
			useColorMultiply = filter.useColorMultiply
			colorMultiplyColor = Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyO)
			useSaturation = filter.useSaturation
			saturation = filter.saturation
			useBrightness = filter.useBrightness
			brightness = filter.brightness
			useGrayscale = filter.useGrayscale
			grayscale = filter.grayscale
			useOpacity = filter.useOpacity
			opacity = filter.opacity
			useBlur = filter.useBlur
			blur = filter.blur
		}
	}
	
	func assignFilterModelToAppStorage(filter: FilterModel?) {
		if let filter = filter {
			invertColors = filter.invertColors
			useHueRotation = filter.useHueRotation
			hueRotation = filter.hueRotation
			useContrast = filter.useContrast
			contrast = filter.contrast
			useColorMultiply = filter.useColorMultiply
			colorMultiplyColor = Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyO)
			useSaturation = filter.useSaturation
			saturation = filter.saturation
			useSaturation = filter.useSaturation
			saturation = filter.saturation
			useBrightness = filter.useBrightness
			brightness = filter.brightness
			useGrayscale = filter.useGrayscale
			grayscale = filter.grayscale
			useOpacity = filter.useOpacity
			opacity = filter.opacity
			useBlur = filter.useBlur
			blur = filter.blur
		}
	}
	
#if os(iOS)
	@MainActor func getFilteredImage(filterModel: FilterModel) -> Image {
		let renderer = ImageRenderer(content: getThumbnailImage().resizable().aspectRatio(contentMode: .fit)
			.if(filterModel.useHueRotation, transform: { view in
				view.hueRotation(.degrees(filterModel.hueRotation))
			}).if(filterModel.useContrast, transform: { view in
				view.contrast(filterModel.contrast)
			}).if(filterModel.invertColors, transform: { view in
				view.colorInvert()
			}).if(filterModel.useColorMultiply, transform: { view in
				view.colorMultiply(Color(.sRGB, red: filterModel.colorMultiplyR, green: filterModel.colorMultiplyG, blue: filterModel.colorMultiplyB, opacity: filterModel.colorMultiplyO))
			}).if(filterModel.useSaturation, transform: { view in
				view.saturation(filterModel.saturation)
			}).if(filterModel.useBrightness, transform: { view in
				view.brightness(filterModel.brightness)
			}).if(filterModel.useGrayscale, transform: { view in
				view.grayscale(filterModel.grayscale)
			}).if(filterModel.useOpacity, transform: { view in
				view.opacity(filterModel.opacity)
			}).if(filterModel.useBlur) { view in
				view.blur(radius: filterModel.blur)
			})
		
		if let uiImage = renderer.uiImage {
			return Image(uiImage: uiImage)
		}
		return Image(uiImage: UIImage(named: "FallColors") ?? UIImage())
	}
#else
	@MainActor func getFilteredImage(forSharing: Bool = false) -> NSImage{
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
	
#if os(iOS)
	@MainActor func getFilteredImage(filter: Filter) -> Image {
		let renderer = ImageRenderer(content: getThumbnailImage().resizable().aspectRatio(contentMode: .fit)
			.if(filter.useHueRotation, transform: { view in
				view.hueRotation(.degrees(filter.hueRotation))
			}).if(filter.useContrast, transform: { view in
				view.contrast(filter.contrast)
			}).if(filter.invertColors, transform: { view in
				view.colorInvert()
			}).if(filter.useColorMultiply, transform: { view in
				view.colorMultiply(Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyO))
			}).if(filter.useSaturation, transform: { view in
				view.saturation(filter.saturation)
			}).if(filter.useBrightness, transform: { view in
				view.brightness(filter.brightness)
			}).if(filter.useGrayscale, transform: { view in
				view.grayscale(filter.grayscale)
			}).if(filter.useOpacity, transform: { view in
				view.opacity(filter.opacity)
			}).if(filter.useBlur) { view in
				view.blur(radius: filter.blur)
			})
		
		if let uiImage = renderer.uiImage {
			return Image(uiImage: uiImage)
		}
		return Image(uiImage: UIImage(named: "FallColors") ?? UIImage())
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
}

