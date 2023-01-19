//
//  FiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/16/23.
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif
struct FiltersView: View {
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
	@EnvironmentObject var imageDataStore: ImageDataStore
	@Binding var showing: Bool
	@State var filterType = FilterType.presets.rawValue
    var body: some View {
		#if os(macOS)
		VStack(alignment: .center, content: {
			Picker(selection: $filterType) {
				ForEach(FilterType.allCases, id: \.rawValue) { filterType in
					Text(filterType.rawValue)
				}
			} label: {
				Text("Filters Picker")
			}.pickerStyle(.segmented).labelsHidden().frame(width: 300)
			List {
				ForEach(presetFilters, id: \.id) { filter in
					VStack {
						getFilteredImage(filter: filter).frame(width: 300, height: 175)
						Text(filter.name)
					}
				}
			}.listStyle(.sidebar)
		}).frame(width: 350).toolbar(content: {
			HStack {
				Spacer(minLength: 275)
				Button {
					showing = false
				} label: {
					Text("Cancel")
				}
			}.frame(maxWidth: 350)

		}).frame(width: 350, height: 615, alignment: .topLeading).padding()
			
				#else
		NavigationStack {
			VStack(alignment: .center, content: {
				Picker(selection: $filterType) {
					ForEach(FilterType.allCases, id: \.rawValue) { filterType in
						/*if filterType == FilterType.favorites {
							Label("Favorites", systemImage: "heart.fill").labelStyle(.iconOnly)
						} else if filterType == FilterType.presets {
							Label("Presets", systemImage: "star.fill").labelStyle(.iconOnly)
						} else {*/
							Text(filterType.rawValue)
						//}
					}
				} label: {
					Text("Filters Picker")
				}.pickerStyle(.segmented).labelsHidden()
				List {
					ForEach(presetFilters, id: \.id) { filter in
						VStack {
							getFilteredImage(filter: filter).frame(width: 250, height: 175)
							Text(filter.name)
						}
					}
				}.listStyle(.sidebar).frame(width: 300)
			}).toolbar {
				ToolbarItem(placement: .navigation, content: {
					Button {
					} label: {
						Text("Edit")
					}
				})
				/*
					ToolbarItem(placement: .principal, content: {
						
						Picker(selection: $filterType) {
							ForEach(FilterType.allCases, id: \.rawValue) { filterType in
								/*if filterType == FilterType.favorites {
									Label("Favorites", systemImage: "heart.fill").labelStyle(.iconOnly)
								} else if filterType == FilterType.presets {
									Label("Presets", systemImage: "star.fill").labelStyle(.iconOnly)
								} else {*/
									Text(filterType.rawValue)
								//}
							}
						} label: {
							Text("Filters Picker")
						}.pickerStyle(.segmented).labelsHidden()
					})
				 */
					ToolbarItem(placement: .primaryAction, content: {
						Button {
							showing = false
						} label: {
							Text("Cancel")
						}
					})
				
			}
		}
#endif
    }
	
	func getFilteredImage(filter: FilterModel) -> some View {
		return getImage().resizable().aspectRatio(contentMode: .fit).if(filter.invertColors, transform: { view in
			view.colorInvert()
		}).if(filter.useHueRotation, transform: { view in
			view.hueRotation(.degrees(filter.hueRotation))
		}).if(filter.useContrast, transform: { view in
			view.contrast(filter.contrast)
		}).if(filter.useColorMultiply, transform: { view in
			view.colorMultiply(Color(.sRGB, red: filter.colorMultiplyR, green: filter.colorMultiplyG, blue: filter.colorMultiplyB, opacity: filter.colorMultiplyA))
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
struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
 */

enum FilterType: String, CaseIterable {
	case saved = "Saved"
	case favorites = "Favorites"
	case presets = "Presets"
}
