//
//  PresetFiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/28/23.
//

import SwiftUI

struct PresetFiltersView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@AppStorage("imageInvertColors") private var invertColors: Bool = false
	@AppStorage("imageHueRotation") private var hueRotation: Double = 0
	@AppStorage("imageUseHueRotation") private var useHueRotation: Bool = false
	@AppStorage("imageContrast") private var contrast: Double = 1
	@AppStorage("imageUseContrast") private var useContrast: Bool = false
	@AppStorage("imageUseColorMultiply") private var useColorMultiply: Bool = false
	@AppStorage("imageColorMultiplyColor") private var colorMultiplyColor: Color = Color.blue
	@AppStorage("imageUseSaturation") private var useSaturation: Bool = false
	@AppStorage("imageSaturation") private var saturation: Double = 1
	@AppStorage("imageUseGrayscale") private var useGrayscale: Bool = false
	@AppStorage("imageGrayscale") private var grayscale: Double = 0
	@AppStorage("imageUseOpacity") private var useOpacity: Bool = false
	@AppStorage("imageOpacity") private var opacity: Double = 1
	@AppStorage("imageUseBlur") private var useBlur: Bool = false
	@AppStorage("imageBlur") private var blur: Double = 0
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@EnvironmentObject var imageDataStore: ImageDataStore
	@Binding var showing: Bool
	@State var selectedPreset: FilterModel? = nil
	@Binding var searchString: String
    var body: some View {
			List(selection: $selectedPreset) {
				ForEach(presets, id: \.self) { filter in
					VStack {
						HStack {
							Spacer()
							getFilteredImage(filter: filter).frame(width: 250, height: 175)
							Spacer()
						}
						HStack {
							Spacer()
							Text(filter.name)
							Spacer()
						}
					}
				}
			}.listStyle(.sidebar)
			.toolbar(content: {
				Button {
					showing = false
				} label: {
					Text("Cancel")
				}
				Button {
					asignPresetFilterComponentsToAppStorage()
					showing = false
				} label: {
					Text("Apply Filter")
				}.disabled(selectedPreset == nil).keyboardShortcut(.defaultAction)

			})
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
	
	var presets: [FilterModel] {
		if searchString.isEmpty {
			return presetFilters
		} else {
			return presetFilters.filter { filterModel in
				filterModel.name.lowercased().contains(searchString.lowercased())
			}
		}
	}
	
	func getFilteredImage(filter: FilterModel) -> some View {
		return getImage().resizable().aspectRatio(contentMode: .fit).if(filter.invertColors, transform: { view in
			view.colorInvert()
		}).if(filter.useHueRotation, transform: { view in
			view.hueRotation(.degrees(filter.hueRotation))
		}).if(filter.useContrast, transform: { view in
			view.contrast(filter.contrast)
		}).if(filter.useColorMultiply, transform: { view in
			view.colorMultiply(Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyO))
		}).if(filter.useSaturation, transform: { view in
				view.saturation(filter.saturation)
			}).if(filter.useGrayscale, transform: { view in
				view.grayscale(filter.grayscale)
			}).if(filter.useOpacity, transform: { view in
				view.opacity(filter.opacity)
			}).if(filter.useBlur) { view in
			view.blur(radius: filter.blur)
		}
	}
	
	func asignPresetFilterComponentsToAppStorage() {
		if let filter = selectedPreset {
			invertColors = filter.invertColors
			useHueRotation = filter.useHueRotation
			hueRotation = filter.hueRotation
			useContrast = filter.useContrast
			contrast = filter.contrast
			useColorMultiply = filter.useColorMultiply
			colorMultiplyColor = Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyO)
			useSaturation = filter.useSaturation
			saturation = filter.saturation
			useGrayscale = filter.useGrayscale
			grayscale = filter.grayscale
			useOpacity = filter.useOpacity
			opacity = filter.opacity
			useBlur = filter.useBlur
			blur = filter.blur
		}
	}
}

/*
struct PresetFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        PresetFiltersView()
    }
}
*/