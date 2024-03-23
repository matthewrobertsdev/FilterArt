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
						Toggle("", isOn: $imageViewModel.useHueRotation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useHueRotation) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						HueRotationControl(hueRotation: $imageViewModel.hueRotation, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useHueRotation)
					}
				case .contrast:
					HStack {
						Toggle("", isOn: $imageViewModel.useContrast).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useContrast) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						ContrastControl(contrast: $imageViewModel.contrast, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useContrast)
					}
				case .invert:
					EmptyView()
				case .colorMultiply:
					HStack {
						Toggle("", isOn: $imageViewModel.useColorMultiply).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useColorMultiply) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						ColorMultiplyControl(colorMultiplyColor: $imageViewModel.colorMultiplyColor).disabled(!imageViewModel.useColorMultiply).onChange(of: imageViewModel.colorMultiplyColor) { newValue in
							if !imageViewModel.isModifying && lastColorEditDate < Date.now - 1 {
								lastColorEditDate = Date.now
								imageViewModel.storeSnapshot()
							} else {
								let lastIndex = imageViewModel.forUndo.count - 1
								imageViewModel.forUndo[lastIndex].colorMultiplyR = imageViewModel.colorMultiplyColor.components.red
								imageViewModel.forUndo[lastIndex].colorMultiplyG = imageViewModel.colorMultiplyColor.components.green
								imageViewModel.forUndo[lastIndex].colorMultiplyB = imageViewModel.colorMultiplyColor.components.blue
								imageViewModel.forUndo[lastIndex].colorMultiplyO = imageViewModel.colorMultiplyColor.components.opacity
							}
						}.frame(width: 100)
					}
				case .saturation:
					HStack {
						Toggle("", isOn: $imageViewModel.useSaturation).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useSaturation) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						SaturationControl(saturation: $imageViewModel.saturation, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useSaturation)
					}
				case .brightness:
					HStack {
						Toggle("", isOn: $imageViewModel.useBrightness).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useBrightness) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						BrightnessControl(brightness: $imageViewModel.brightness, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useBrightness)
					}
				case .grayscale:
					HStack {
						Toggle("", isOn: $imageViewModel.useGrayscale).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useGrayscale) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						GrayscaleControl(grayscale: $imageViewModel.grayscale, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useGrayscale)
					}
				case .opacity:
					HStack {
						Toggle("", isOn: $imageViewModel.useOpacity).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useOpacity) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						OpacityControl(opacity: $imageViewModel.opacity, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useOpacity)
					}
				case .blur:
					HStack {
						Toggle("", isOn: $imageViewModel.useBlur).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50).controlSize(.small).onChange(of: imageViewModel.useBlur) { newValue in
							if !imageViewModel.isModifying {
								imageViewModel.storeSnapshot()
							}
						}
						BlurControl(blur: $imageViewModel.blur, saveForUndo: {
							imageViewModel.storeSnapshot()
						}).disabled(!imageViewModel.useBlur)
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
