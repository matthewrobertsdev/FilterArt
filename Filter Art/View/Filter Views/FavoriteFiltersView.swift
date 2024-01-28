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
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	
	@Binding var showing: Bool
	
	@State var selectedFavoriteFilter: Filter? = nil
	
	var image: Image = Image(uiImage: UIImage())
	
	init(showing: Binding<Bool>, searchString: String, thumbnailData: Data) {
		_showing = showing
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
		let isFavoritePredicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isFavoritePredicate, searchStringPredicate])
		if searchString == "" {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: isFavoritePredicate)
		} else {
			_favoriteFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
		image = Image(uiImage: UIImage(data: thumbnailData) ?? UIImage())
	}
	
	var body: some View {
		List(selection: $selectedFavoriteFilter) {
			ForEach(favoriteFilters, id: \.self) { filter in
				VStack(alignment: .center) {
						HStack {
							Spacer()
							imageDataStore.getFilteredImage(filter: filter).resizable().aspectRatio(contentMode: .fit)
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
				imageDataStore.asignSavedFilterComponentsToAppStorage(selectedSavedFilter: selectedFavoriteFilter)
				imageDataStore.storeSnapshot()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					NotificationCenter.default.post(name: .endEditing,
																	object: nil, userInfo: nil)
					showing = false
				}
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
				imageDataStore.asignSavedFilterComponentsToAppStorage(selectedSavedFilter: selectedFavoriteFilter)
				imageDataStore.storeSnapshot()
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
	
}

/*
struct FavoriteFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteFiltersView()
    }
}
*/
