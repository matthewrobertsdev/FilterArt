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
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(sortDescriptors: [SortDescriptor(\.saveDate)]) var savedFilters: FetchedResults<Filter>
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
	@State var filterType = FilterType.presets.rawValue
	@State var selectedPreset: FilterModel? = nil
	@State var selectedSavedFilter: Filter? = nil
    var body: some View {
		#if os(macOS)
		VStack(alignment: .center, content: {
			if filterType  == FilterType.presets.rawValue {
				List(selection: $selectedPreset) {
					ForEach(presetFilters, id: \.self) { filter in
						VStack {
							getFilteredImage(filter: filter).frame(width: 300, height: 175)
							Text(filter.name)
						}
					}
				}.listStyle(.sidebar).onChange(of: selectedPreset) { newValue in
					asignFilterComponentsToAppStorage()
					showing = false
				}
			} else if filterType == FilterType.saved.rawValue {
				List(selection: $selectedSavedFilter) {
					ForEach(savedFilters, id: \.self) { filter in
						VStack(alignment: .center) {
							HStack {
								Spacer()
								getFilteredImage(filter: filter).frame(width: 250, height: 175)
								Spacer()
							}
							HStack {
								Spacer()
								Text(filter.name ?? "Saved Filter")
								Spacer()
							}
						}
					}
				}.listStyle(.sidebar)
			} else {
				EmptyView()
			}
		}).safeAreaInset(edge: .top, content: {
			VStack(spacing:0){
				Text("Stored Filters").font(.largeTitle).padding()
				Picker(selection: $filterType) {
					ForEach(FilterType.allCases, id: \.rawValue) { filterType in
						Text(filterType.rawValue)
					}
				} label: {
					Text("Filters Picker")
				}.pickerStyle(.segmented).labelsHidden()
				TextField("", text: .constant(""), prompt: Text("Search \(filterType.lowercased())..."))
			}.background(
				.regularMaterial,
				   in: Rectangle()
			   )
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
				if filterType  == FilterType.presets.rawValue {
					List(selection: $selectedPreset) {
						ForEach(presetFilters, id: \.self) { filter in
							VStack(alignment: .center) {
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
					}.listStyle(.sidebar).onChange(of: selectedPreset) { newValue in
						asignFilterComponentsToAppStorage()
						showing = false
					}
				} else if filterType == FilterType.saved.rawValue {
					List(selection: $selectedSavedFilter) {
						ForEach(savedFilters, id: \.self) { filter in
							VStack(alignment: .center) {
								HStack {
									Spacer()
									getFilteredImage(filter: filter).frame(width: 250, height: 175)
									Spacer()
								}
								HStack {
									Spacer()
									Text(filter.name ?? "Saved Filter")
									Spacer()
								}
							}
						}
					}.listStyle(.sidebar)
				} else {
					EmptyView()
				}
			}).safeAreaInset(edge: .top, content: {
				VStack(spacing:0){
					Picker(selection: $filterType) {
						ForEach(FilterType.allCases, id: \.rawValue) { filterType in
							Text(filterType.rawValue)
						}
					} label: {
						Text("Filters Picker")
					}.pickerStyle(.segmented).labelsHidden().background(
						.regularMaterial,
						in: Rectangle()
					)
					TextField("", text: .constant(""), prompt: Text("Search \(filterType.lowercased())...")).submitLabel(.done).font(.title3).padding(5).background(
						   .regularMaterial,
			in: Rectangle()
				)
				}
			}).toolbar {
				ToolbarItem(placement: .navigation, content: {
					Button {
					} label: {
						Text("Edit")
					}
				})
					ToolbarItem(placement: .primaryAction, content: {
						Button {
							showing = false
						} label: {
							Text("Cancel")
						}
					})
				
			}.navigationTitle(Text("Stored Filters")).navigationBarTitleDisplayMode(.inline)
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
	
	func getFilteredImage(filter: Filter) -> some View {
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
	
	func asignFilterComponentsToAppStorage() {
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
