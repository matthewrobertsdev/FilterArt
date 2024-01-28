//
//  FilterControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct FilterControl: View {
	@Binding private var editMode: ImageEditMode?
	@State private var lastColorEditDate: Date = Date.now
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
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	
	init(editMode: Binding<ImageEditMode?>) {
		_editMode = editMode
	}
    var body: some View {
		Group{
			if editMode == nil {
				EmptyView()
			}
			else {
				switch editMode {
				case .hue:
					HStack {
						Toggle("", isOn: $useHueRotation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useHueRotation) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						HueRotationControl(hueRotation: $hueRotation, saveForUndo: {
							storeSnapshot()
						}).disabled(!useHueRotation)
					}
				case .contrast:
					HStack {
						Toggle("", isOn: $useContrast).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useContrast) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						ContrastControl(contrast: $contrast, saveForUndo: {
							storeSnapshot()
						}).disabled(!useContrast)
					}
				case .invert:
					EmptyView()
				case .colorMultiply:
					HStack {
						Toggle("", isOn: $useColorMultiply).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useColorMultiply) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						ColorMultiplyControl(colorMultiplyColor: $colorMultiplyColor).disabled(!useColorMultiply).onChange(of: colorMultiplyColor) { newValue in
							if !filterStateHistory.isModifying && lastColorEditDate < Date.now - 1 {
								lastColorEditDate = Date.now
								print("abcd store")
								storeSnapshot()
							} else {
								let lastIndex = filterStateHistory.forUndo.count - 1
								filterStateHistory.forUndo[lastIndex].colorMultiplyR = colorMultiplyColor.components.red
								filterStateHistory.forUndo[lastIndex].colorMultiplyG = colorMultiplyColor.components.green
								filterStateHistory.forUndo[lastIndex].colorMultiplyB = colorMultiplyColor.components.blue
								filterStateHistory.forUndo[lastIndex].colorMultiplyO = colorMultiplyColor.components.opacity
							}
						}.frame(width: 100)
					}
				case .saturation:
					HStack {
						Toggle("", isOn: $useSaturation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useSaturation) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						SaturationControl(saturation: $saturation, saveForUndo: {
							storeSnapshot()
						}).disabled(!useSaturation)
					}
				case .brightness:
					HStack {
						Toggle("", isOn: $useBrightness).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBrightness) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						BrightnessControl(brightness: $brightness, saveForUndo: {
							storeSnapshot()
						}).disabled(!useBrightness)
					}
				case .grayscale:
					HStack {
						Toggle("", isOn: $useGrayscale).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useGrayscale) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						GrayscaleControl(grayscale: $grayscale, saveForUndo: {
							storeSnapshot()
						}).disabled(!useGrayscale)
					}
				case .opacity:
					HStack {
						Toggle("", isOn: $useOpacity).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useOpacity) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						OpacityControl(opacity: $opacity, saveForUndo: {
							storeSnapshot()
						}).disabled(!useOpacity)
					}
				case .blur:
					HStack {
						Toggle("", isOn: $useBlur).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBlur) { newValue in
							if !filterStateHistory.isModifying {
								storeSnapshot()
							}
						}
						BlurControl(blur: $blur, saveForUndo: {
							storeSnapshot()
						}).disabled(!useBlur)
					}
				case .none:
					EmptyView()
				}
			}
		}
    }
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
}

/*
#Preview {
    FilterControl()
}
*/
