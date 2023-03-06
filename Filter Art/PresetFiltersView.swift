//
//  PresetFiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/28/23.
//

import SwiftUI

struct PresetFiltersView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(sortDescriptors: [SortDescriptor(\.saveDate)]) var presetFavoriteFiltersFetchRequest: FetchedResults<Filter>
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
	
	init(showing: Binding<Bool>, searchString: Binding<String>) {
		_showing = showing
		_searchString = searchString
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", _searchString.wrappedValue)
		let isFavoritePredicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
		let isPresetPredicate = NSPredicate(format: "isPreset == %@", NSNumber(value: true))
		let favoriteAndPresetPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isFavoritePredicate, isPresetPredicate])
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isFavoritePredicate, isPresetPredicate, searchStringPredicate])
		if _searchString.wrappedValue == "" {
			_presetFavoriteFiltersFetchRequest = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: favoriteAndPresetPredicate)
		} else {
			_presetFavoriteFiltersFetchRequest = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
	}
	
	var body: some View {
		List(selection: $selectedPreset) {
			ForEach(presets, id: \.self) { filterModel in
				VStack {
					HStack {
						Spacer()
						getFilteredImage(filter: filterModel)
#if os(macOS)
								.frame(width: 250, height: 175)
							#else
								.frame(width: 250, height: 175)
							#endif
						Spacer()
					}
					HStack {
						Spacer()
						Text(filterModel.name)
						Spacer()
						Button {
							if !isFavorite(filterModel: filterModel) {
								DispatchQueue.main.async {
									let savedFilter = Filter(context: managedObjectContext)
									savedFilter.blur = filterModel.blur
									savedFilter.colorMultiplyB = filterModel.colorMultiplyB
									savedFilter.colorMultiplyG = filterModel.colorMultiplyG
									savedFilter.colorMultiplyO = filterModel.colorMultiplyO
									savedFilter.colorMultiplyR = filterModel.colorMultiplyR
									savedFilter.contrast = filterModel.contrast
									savedFilter.favoriteDate = Date()
									savedFilter.grayscale = filterModel.grayscale
									savedFilter.hueRotation = filterModel.hueRotation
									savedFilter.id = filterModel.id.description
									savedFilter.invertColors = filterModel.invertColors
									savedFilter.isFavorite = !isFavorite(filterModel: filterModel)
									savedFilter.isPreset = true
									savedFilter.name = filterModel.name
									savedFilter.opacity = filterModel.opacity
									savedFilter.saturation = filterModel.saturation
									savedFilter.saveDate = Date()
									savedFilter.useBlur = filterModel.useBlur
									savedFilter.useColorMultiply = filterModel.useColorMultiply
									savedFilter.useContrast = filterModel.useContrast
									savedFilter.useGrayscale = filterModel.useGrayscale
									savedFilter.useHueRotation = filterModel.useHueRotation
									savedFilter.useOpacity = filterModel.useOpacity
									savedFilter.useSaturation = filterModel.useSaturation
									do {
										try managedObjectContext.save()
									} catch {
										
									}
								}
							} else {
								let filtersToDelete = presetFavoriteFiltersFetchRequest.filter({ filter in
									filterModel.id.description == filter.id
								})
								for toDelete in filtersToDelete {
									managedObjectContext.delete(toDelete)
								}
								do {
									try managedObjectContext.save()
								} catch {
									
								}
							}
						} label: {
							Image(systemName: isFavorite(filterModel: filterModel) ? "heart.fill" : "heart").font(.title)
						}.buttonStyle(.plain)
					}.frame(maxWidth: 300)
					Spacer()
				}
			}
		}.listStyle(.sidebar)
#if os(iOS)
			.onChange(of: selectedPreset) { newValue in
				NotificationCenter.default.post(name: .endEditing,
																object: nil, userInfo: nil)
				asignPresetFilterComponentsToAppStorage()
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
					asignPresetFilterComponentsToAppStorage()
					showing = false
				} label: {
					Text("Apply Filter")
				}.disabled(selectedPreset == nil).keyboardShortcut(.defaultAction)
				
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
	
	func isFavorite(filterModel: FilterModel) -> Bool {
		return presetFavoriteFiltersFetchRequest.contains { filter in
			guard let filterId = filter.id else {
				return false
			}
			return filterId == filterModel.id.description
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
