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
	@Binding var showing: Bool
	@State var selectedFavoriteFilter: Filter? = nil
	
	init(showing: Binding<Bool>, searchString: String) {
		_showing = showing
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
		let isFavoritePredciate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isFavoritePredciate, searchStringPredicate])
		if searchString == "" {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: isFavoritePredciate)
		} else {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
	}
	
	var body: some View {
		List(selection: $selectedFavoriteFilter) {
			ForEach(favoriteFilters, id: \.self) { filter in
				VStack(alignment: .center) {
					ZStack {
						HStack {
							Spacer()
							getFilteredImage(filter: filter).frame(width: 250, height: 175).transition(.scale).transition(.move(edge: .leading))
							Spacer()
						}
						VStack {
							Spacer()
							HStack {
								Spacer()
								Button {
									filter.isFavorite.toggle()
									do {
										try managedObjectContext.save()
									} catch {
										
									}
								} label: {
									Image(systemName: filter.isFavorite ? "heart.fill" : "heart").font(.title)
								}.buttonStyle(.plain)
							}
						}
					}
					HStack {
						Spacer()
						Text(filter.name ?? "Saved Filter")
						Spacer()
					}
				}
			}
		}.listStyle(.sidebar)
		#if os(iOS)
			.onChange(of: selectedSavedFilter) { newValue in
			asignSavedFilterComponentsToAppStorage()
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
				asignSavedFilterComponentsToAppStorage()
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
struct FavoriteFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteFiltersView()
    }
}
*/
