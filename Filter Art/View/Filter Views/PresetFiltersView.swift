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
	@AppStorage("imageUseBrightness") private var useBrightness: Bool = true
	@AppStorage("imageBrightness") private var brightness: Double = 0
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
	@State var selectedPreset: FilterModel? = nil
	@Binding var searchString: String
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
						getFilteredImage(filterModel: filterModel).resizable().aspectRatio(contentMode: .fit)
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
					asignPresetFilterComponentsToAppStorage()
					storeSnapshot()
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
	
	func getImage() -> Image {
		if useOriginalImage {
			return Image("FallColors")
		} else {
#if os(macOS)
			return Image(nsImage: (NSImage(data: imageDataStore.imageData) ?? NSImage()))
#else
			return image
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
	
#if os(iOS)
	@MainActor func getFilteredImage(filterModel: FilterModel) -> Image {
		var originalWidth = 200.0
		var originalHeight = 200.0
		var desiredWidth = 200.0
		var desiredHeight = 200.0
		if useOriginalImage {
			desiredWidth = 200.0
			desiredHeight = 200.0
		} else {
			let uiImage = (UIImage(data: imageDataStore.imageData)  ?? UIImage())
			originalWidth = uiImage.size.width
			originalHeight = uiImage.size.height
			if originalWidth >= originalHeight && originalWidth >= 200.0 {
				let scaleFactor = 200.0/originalWidth
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else if originalHeight >= originalWidth && originalHeight >= 200.0 {
				let scaleFactor = 200.0/originalHeight
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else {
				desiredWidth = originalWidth
				desiredHeight = originalHeight
			}
		}
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit)
			.if(filterModel.useHueRotation, transform: { view in
				view.hueRotation(.degrees(filterModel.hueRotation))
			}).if(filterModel.useContrast, transform: { view in
				view.contrast(filterModel.contrast)
			}).if(filterModel.invertColors, transform: { view in
				view.colorInvert()
			}).if(filterModel.useColorMultiply, transform: { view in
				view.colorMultiply(Color(.sRGB, red: filterModel.colorMultiplyR, green: filterModel.colorMultiplyG, blue: filterModel.colorMultiplyB, opacity: filterModel.colorMultiplyO))
			}).if(filterModel.useSaturation, transform: { view in
				view.saturation(filterModel.saturation)
			}).if(filterModel.useBrightness, transform: { view in
				view.brightness(filterModel.brightness)
			}).if(filterModel.useGrayscale, transform: { view in
				view.grayscale(filterModel.grayscale)
			}).if(filterModel.useOpacity, transform: { view in
				view.opacity(filterModel.opacity)
			}).if(filterModel.useBlur) { view in
				view.blur(radius: filterModel.blur)
			})
		
		if let uiImage = renderer.uiImage {
			print("01/22/2024 success")
			return Image(uiImage: uiImage)
		}
		return Image(uiImage: UIImage(named: "FallColors") ?? UIImage())
	}
#else
	@MainActor func getFilteredImage(forSharing: Bool = false) -> NSImage{
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let nsImage = (NSImage(data: imageDataStore.imageData)  ?? NSImage())
			originalWidth = nsImage.size.width
			originalHeight = nsImage.size.height
			if originalWidth >= originalHeight && originalWidth >= 1000.0 {
				let scaleFactor = 1000.0/originalWidth
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else if originalHeight >= originalWidth && originalHeight >= 1000.0 {
				let scaleFactor = 1000.0/originalHeight
				desiredWidth =  originalWidth * scaleFactor
				desiredHeight = originalHeight * scaleFactor
			} else {
				desiredWidth = originalWidth
				desiredHeight = originalHeight
			}
		}
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		}).if(useHueRotation, transform: { view in
			view.hueRotation(.degrees(hueRotation))
		}).if(useContrast, transform: { view in
			view.contrast(contrast)
		}).if(invertColors, transform: { view in
			view.colorInvert()
		}).if(useColorMultiply, transform: { view in
			view.colorMultiply(colorMultiplyColor)
		}).if(useSaturation, transform: { view in
			view.saturation(saturation)
		}).if(useBrightness, transform: { view in
			view.brightness(brightness)
		}).if(useGrayscale, transform: { view in
			view.grayscale(grayscale)
		}).if(useOpacity, transform: { view in
			view.opacity(opacity)
		}).if(useBlur) { view in
			view.blur(radius: blur)
		})
		if let nsImage = renderer.nsImage {
			return  nsImage
		}
		return NSImage(named: "FallColors") ?? NSImage()
	}
#endif
	
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
			useSaturation = filter.useSaturation
			saturation = filter.saturation
			useBrightness = filter.useBrightness
			brightness = filter.brightness
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
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
}

/*
 struct PresetFiltersView_Previews: PreviewProvider {
 static var previews: some View {
 PresetFiltersView()
 }
 }
 */
