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
	
	@EnvironmentObject var imageViewModel: ImageViewModel
	
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
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						HueRotationControl(hueRotation: $hueRotation, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useHueRotation)
					}
				case .contrast:
					HStack {
						Toggle("", isOn: $useContrast).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useContrast) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						ContrastControl(contrast: $contrast, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useContrast)
					}
				case .invert:
					EmptyView()
				case .colorMultiply:
					HStack {
						Toggle("", isOn: $useColorMultiply).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useColorMultiply) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						ColorMultiplyControl(colorMultiplyColor: $colorMultiplyColor).disabled(!useColorMultiply).onChange(of: colorMultiplyColor) { newValue in
							if !imageViewModel.isModifying && lastColorEditDate < Date.now - 1 {
								lastColorEditDate = Date.now
								imageViewModel.storeSnapshot()
							} else {
								let lastIndex = imageViewModel.forUndo.count - 1
								imageViewModel.forUndo[lastIndex].colorMultiplyR = colorMultiplyColor.components.red
								imageViewModel.forUndo[lastIndex].colorMultiplyG = colorMultiplyColor.components.green
								imageViewModel.forUndo[lastIndex].colorMultiplyB = colorMultiplyColor.components.blue
								imageViewModel.forUndo[lastIndex].colorMultiplyO = colorMultiplyColor.components.opacity
							}
						}.frame(width: 100)
					}
				case .saturation:
					HStack {
						Toggle("", isOn: $useSaturation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useSaturation) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						SaturationControl(saturation: $saturation, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useSaturation)
					}
				case .brightness:
					HStack {
						Toggle("", isOn: $useBrightness).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBrightness) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						BrightnessControl(brightness: $brightness, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useBrightness)
					}
				case .grayscale:
					HStack {
						Toggle("", isOn: $useGrayscale).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useGrayscale) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						GrayscaleControl(grayscale: $grayscale, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useGrayscale)
					}
				case .opacity:
					HStack {
						Toggle("", isOn: $useOpacity).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useOpacity) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						OpacityControl(opacity: $opacity, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useOpacity)
					}
				case .blur:
					HStack {
						Toggle("", isOn: $useBlur).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: useBlur) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						BlurControl(blur: $blur, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!useBlur)
					}
				case .none:
					EmptyView()
				}
			}
		}
    }
}

/*
#Preview {
    FilterControl()
}
*/


enum ImageEditMode: String, CaseIterable {
	case hue
	case contrast
	case invert
	case colorMultiply = "Color Multiply"
	case saturation
	case brightness
	case grayscale
	case opacity
	case blur
}

struct ImageEditModeData {
	var mode: ImageEditMode
	var imageName: String
}

let imageEditModesData = [ImageEditModeData(mode: .hue, imageName: "paintbrush"),
						  ImageEditModeData(mode: .contrast, imageName: "circle.lefthalf.filled"),
						  ImageEditModeData(mode: .invert, imageName: "lightswitch.off"),
						  ImageEditModeData(mode: .colorMultiply, imageName: "paintpalette"),
						  ImageEditModeData(mode: .saturation, imageName: "sun.max"),
						  ImageEditModeData(mode: .brightness, imageName: "lightbulb"),
						  ImageEditModeData(mode: .grayscale, imageName: "circle.dotted"),
						  ImageEditModeData(mode: .opacity, imageName: "circle"),
						  ImageEditModeData(mode: .blur, imageName: "camera.filters")]
