//
//  FilterControls.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct FilterControls: View {
	@State private var editMode: ImageEditMode? = nil
	@Binding var renderedImage: Image
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@EnvironmentObject var imageDataStore: ImageDataStore
	var proxy: GeometryProxy
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
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
    var body: some View {
		Group {
			VStack {
				ScrollView([.horizontal]) {
					HStack(alignment: .top) {
						ForEach(imageEditModesData, id: \.mode.rawValue) { modeData in
							VStack(spacing: 5) {
								Text(modeData.mode.rawValue.capitalized).font(.system(.callout)).fixedSize().if(modeData.mode == editMode) { view in
									view.foregroundColor(Color.accentColor)
								}
								if modeData.mode == .invert {
									Toggle(isOn: $invertColors) {
										Text("")
									}.toggleStyle(.switch).tint(Color.accentColor).onChange(of: invertColors) { newValue in
										if !filterStateHistory.isModifying {
											storeSnapshot()
										}
									}.frame(width: 50)
								} else {
									Image(systemName: modeData.imageName).font(.system(.title)).if(modeData.mode == editMode) { view in
										view.foregroundColor(Color.accentColor)
									}
								}
							}.padding(.horizontal).padding(.vertical, 2.5).contentShape(Rectangle()).if(modeData.mode == editMode) { view in
#if os(macOS)
								view.background(Color.accentColor.opacity(colorScheme == .dark ? 0.10 : 0.20)).cornerRadius(10)
#else
								view.background(Color.accentColor.opacity(0.25)).cornerRadius(10)
#endif
							}.onTapGesture {
								if modeData.mode != .invert {
									
									editMode = modeData.mode
								}
							}.onChange(of: editMode) { newValue in
#if os(macOS)
								NSColorPanel.shared.close()
#endif
							}
						}.padding(.vertical, 5)
					}
#if os(iOS)
					.if(proxy.size.width > 1100) { view in
						view.frame(width: proxy.size.width)
					}
#else
					.frame(width: proxy.size.width)
#endif
				}
			}
			FilterControl(editMode: $editMode).environmentObject(filterStateHistory).frame(maxWidth: 600)
			InfoSeperator()
			HStack(spacing: 30) {
				Button {
					resetAll()
					if !filterStateHistory.isModifying {
						storeSnapshot()
					}
				} label: {
					Text("Reset All")
				}.disabled(shouldDisableResetAll())
				Button {
					handleUndo()
				} label: {
					Text("Undo")
				}.disabled(!filterStateHistory.canUndo)
				Button {
					handleRedo()
				} label: {
					Text("Redo")
				}.disabled(!filterStateHistory.canRedo)
			}
#if os(macOS)
			.padding(.top)
#endif
		}
		.onChange(of: useHueRotation) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: hueRotation) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useContrast) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: contrast) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: invertColors) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useColorMultiply) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: colorMultiplyColor) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useSaturation) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: saturation) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useBrightness) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: brightness) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useGrayscale) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: grayscale) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useOpacity) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: opacity) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: useBlur) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: blur) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}.onChange(of: blur) { _ in
			renderedImage = Image(uiImage: getFilteredImage())
		}
    }
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
	
	func handleUndo() {
		restoreSnapshot(stateToRestore: filterStateHistory.undo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
	func handleRedo() {
		restoreSnapshot(stateToRestore: filterStateHistory.redo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
	
	func restoreSnapshot(stateToRestore: FilterModel?) {
		if let stateToRestore = stateToRestore {
			invertColors = stateToRestore.invertColors
			hueRotation = stateToRestore.hueRotation
			useHueRotation = stateToRestore.useHueRotation
			contrast = stateToRestore.contrast
			brightness = stateToRestore.brightness
			useBrightness = stateToRestore.useBrightness
			useContrast = stateToRestore.useContrast
			useColorMultiply = stateToRestore.useColorMultiply
			colorMultiplyColor = Color(red: stateToRestore.colorMultiplyR, green: stateToRestore.colorMultiplyG, blue: stateToRestore.colorMultiplyB, opacity: stateToRestore.colorMultiplyO)
			useSaturation = stateToRestore.useSaturation
			saturation = stateToRestore.saturation
			useGrayscale = stateToRestore.useGrayscale
			grayscale = stateToRestore.grayscale
			useOpacity = stateToRestore.useOpacity
			opacity = stateToRestore.opacity
			useBlur = stateToRestore.useOpacity
			blur = stateToRestore.blur
		}
	}
	
	func resetAll() {
			invertColors = originalFilter.invertColors
			hueRotation = originalFilter.hueRotation
			useHueRotation = originalFilter.useHueRotation
			contrast = originalFilter.contrast
			brightness = originalFilter.brightness
			useBrightness = originalFilter.useBrightness
			useContrast = originalFilter.useContrast
			useColorMultiply = originalFilter.useColorMultiply
			colorMultiplyColor = Color(red: originalFilter.colorMultiplyR, green: originalFilter.colorMultiplyG, blue: originalFilter.colorMultiplyB, opacity: originalFilter.colorMultiplyO)
			useSaturation = originalFilter.useSaturation
			saturation = originalFilter.saturation
			useGrayscale = originalFilter.useGrayscale
			grayscale = originalFilter.grayscale
			useOpacity = originalFilter.useOpacity
			opacity = originalFilter.opacity
			useBlur = originalFilter.useOpacity
			blur = originalFilter.blur
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
		let renderer = ImageRenderer(content:  getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
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
    FilterControls()
}
*/
