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
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	
	@Binding var showing: Bool
	@Binding var searchString: String
	
	@State var selectedPreset: FilterModel? = nil
	
	var image: Image = Image(uiImage: UIImage())
	
	init(showing: Binding<Bool>, searchString: Binding<String>, thumbnailData: Data) {
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
		image = Image(uiImage: UIImage(data: thumbnailData) ?? UIImage())
	}
	
	var body: some View {
		List(selection: $selectedPreset) {
			ForEach(presets, id: \.self) { filterModel in
				VStack {
					HStack {
						Spacer()
						imageDataStore.getFilteredImage(filterModel: filterModel).resizable().aspectRatio(contentMode: .fit)
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
				imageDataStore.assignFilterModelToAppStorage(filter: selectedPreset)
				imageDataStore.storeSnapshot()
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
					imageDataStore.storeSnapshot()
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
						NotificationCenter.default.post(name: .endEditing,
																		object: nil, userInfo: nil)
						showing = false
					}
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
	
	var presets: [FilterModel] {
		if searchString.isEmpty {
			return presetFilters
		} else {
			return presetFilters.filter { filterModel in
				filterModel.name.lowercased().contains(searchString.lowercased())
			}
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
