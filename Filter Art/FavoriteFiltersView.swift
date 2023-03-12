//
//  FavoriteFiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/29/23.
//

import SwiftUI

struct FavoriteFiltersView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(sortDescriptors: [SortDescriptor(\.saveDate)]) var favoriteFilters: FetchedResults<Filter>
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
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@Binding var showing: Bool
	@State var selectedFavoriteFilter: Filter? = nil
	
	init(showing: Binding<Bool>, searchString: String) {
		_showing = showing
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
		let isFavoritePredicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isFavoritePredicate, searchStringPredicate])
		if searchString == "" {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: isFavoritePredicate)
		} else {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
	}
	
	var body: some View {
		List(selection: $selectedFavoriteFilter) {
			ForEach(favoriteFilters, id: \.self) { filter in
				VStack(alignment: .center) {
						HStack {
							Spacer()
							getFilteredImage(filter: filter)
#if os(macOS)
								.frame(width: 250, height: 175)
							#else
								.frame(width: 250, height: 175)
							#endif
								.transition(.scale).transition(.move(edge: .leading))
							Spacer()
						}
					HStack {
						Spacer()
						Text(filter.name ?? "Saved Filter")
						Spacer()
							Button {
								if filter.isFavorite && filter.isPreset {
									managedObjectContext.delete(filter)
								} else {
									filter.isFavorite.toggle()
								}
								do {
									try managedObjectContext.save()
								} catch {
									
								}
							} label: {
								Image(systemName: filter.isFavorite ? "heart.fill" : "heart").font(.title)
							}.buttonStyle(.plain)
					}.frame(maxWidth: 300)
					Spacer()
				}
			}
		}.listStyle(.sidebar)
		#if os(iOS)
			.onChange(of: selectedFavoriteFilter) { newValue in
				NotificationCenter.default.post(name: .endEditing,
																object: nil, userInfo: nil)
			asignSavedFilterComponentsToAppStorage()
				storeSnapshot()
			showing = false
		}
		#endif
		#if os(macOS)
		.toolbar(content: {
			Button {
				showing = false
			} label: {
				Text("Cancel")
			}
			Button {
				NotificationCenter.default.post(name: .endEditing,
																object: nil, userInfo: nil)
				asignSavedFilterComponentsToAppStorage()
				storeSnapshot()
				showing = false
			} label: {
				Text("Apply Filter")
			}.disabled(selectedFavoriteFilter == nil).keyboardShortcut(.defaultAction)
			
		})
		#else
		.toolbar {
			ToolbarItem(placement: .primaryAction, content: {
				Button {
					showing = false
				} label: {
					Text("Cancel")
				}
			})
			
		}
#endif
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
	
	func asignSavedFilterComponentsToAppStorage() {
		if let filter = selectedFavoriteFilter {
			printFilter(filter: filter)
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
	
	func printFilter(filter: Filter) {
		var descriptionString = "Printing filter: "
		descriptionString += "name: \(filter.name ?? "unknown"), "
		descriptionString += "id: \(filter.id ?? "unknown"), "
		descriptionString += "isPreset: \(filter.isPreset), "
		descriptionString += "isFavorite: \(filter.isFavorite), "
		descriptionString += "invertColors: \(filter.invertColors), "
		descriptionString += "useHueRotation: \(filter.useHueRotation), "
		descriptionString += "hueRotation: \(filter.hueRotation), "
		descriptionString += "useContrast: \(filter.useContrast), "
		descriptionString += "contrast: \(filter.contrast), "
		descriptionString += "useColorMultiply: \(filter.useColorMultiply), "
		descriptionString += "colorMultiplyR: \(filter.colorMultiplyR), "
		descriptionString += "colorMultiplyG: \(filter.colorMultiplyG), "
		descriptionString += "colorMultiplyB: \(filter.colorMultiplyB), "
		descriptionString += "colorMultiplyO: \(filter.colorMultiplyO), "
		descriptionString += "useStauration: \(filter.useSaturation), "
		descriptionString += "saturation: \(filter.saturation), "
		descriptionString += "useGrayscale: \(filter.useGrayscale), "
		descriptionString += "useOpacity: \(filter.useOpacity), "
		descriptionString += "opcaity: \(filter.opacity), "
		descriptionString += "useBlur: \(filter.useBlur), "
		descriptionString += "blur: \(filter.blur), "
		print(descriptionString)
	}
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
	
}

/*
struct FavoriteFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteFiltersView()
    }
}
*/
