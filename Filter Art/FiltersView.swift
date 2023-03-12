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
	@FocusState private var searchFieldInFocus: Bool
	@EnvironmentObject var imageDataStore: ImageDataStore
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@Binding var showing: Bool
	@AppStorage("filterType") var filterType = FilterType.presets.rawValue
	@State var selectedPreset: FilterModel? = nil
	@State var searchString = ""
    var body: some View {
		#if os(macOS)
		VStack(alignment: .center, content: {
			if filterType  == FilterType.presets.rawValue {
				PresetFiltersView(showing: $showing, searchString: $searchString)
					.environmentObject(filterStateHistory)
			} else if filterType == FilterType.saved.rawValue {
				SavedFiltersView(showing: $showing, searchString: searchString)
					.environmentObject(filterStateHistory)
			} else {
				FavoriteFiltersView(showing: $showing, searchString: searchString)
					.environmentObject(filterStateHistory)
			}
		}).safeAreaInset(edge: .top, content: {
			VStack(spacing:0){
				Text("Stored Filters").font(.title2).padding(5)
				Picker(selection: $filterType) {
					ForEach(FilterType.allCases, id: \.rawValue) { filterType in
						Text(filterType.rawValue)
					}
				} label: {
					Text("Filters Picker")
				}.pickerStyle(.segmented).labelsHidden()
				TextField("", text: $searchString, prompt: Text("Search \(filterType.lowercased())...")).focused($searchFieldInFocus)
			}.background(
				.regularMaterial,
				   in: Rectangle()
			   )
		   }).frame(width: 325, height: 500, alignment: .topLeading).padding().onChange(of: filterType) { _ in
			   searchString = ""
		   }
				#else
		NavigationStack {
			VStack(alignment: .center, content: {
				if filterType  == FilterType.presets.rawValue {
					PresetFiltersView(showing: $showing, searchString: $searchString)
				} else if filterType == FilterType.saved.rawValue {
					SavedFiltersView(showing: $showing, searchString: searchString)
				} else {
					FavoriteFiltersView(showing: $showing, searchString: searchString)
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
					TextField("", text: $searchString, prompt: Text("Search \(filterType.lowercased())...")).focused($searchFieldInFocus).submitLabel(.search).font(.title3).padding(5).background(
						   .regularMaterial,
			in: Rectangle()
				)
				}
			}).navigationTitle(Text("Stored Filters")).navigationBarTitleDisplayMode(.inline)
		}.onChange(of: filterType) { _ in
			searchString = ""
			searchFieldInFocus = false
		}
#endif
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
