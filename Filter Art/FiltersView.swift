//
//  FiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/16/23.
//

import SwiftUI

struct FiltersView: View {
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
		}).frame(width: 650).toolbar(content: {
			HStack {
				Spacer(minLength: 575)
				Button {
					showing = false
				} label: {
					Text("Cancel")
				}
			}.frame(maxWidth: 650)

		}).frame(width: 650, height: 615, alignment: .topLeading).padding()
			
				#else
		NavigationStack {
			VStack {
				Text("Hello, World!")
			}.frame(minHeight: 525, maxHeight: 525).toolbar {
				Picker(selection: $filterType) {
					ForEach(FilterType.allCases, id: \.rawValue) { filterType in
						if filterType == FilterType.favorites {
							Label("Favorites", systemImage: "heart.fill").labelStyle(.iconOnly)
						} else if filterType == FilterType.presets {
							Label("Presets", systemImage: "star.fill").labelStyle(.iconOnly)
						} else {
							Text(filterType.rawValue)
						}
					}
				} label: {
					Text("Filters Picker")
				}.pickerStyle(.segmented).labelsHidden()
				Button {
					showing = false
				} label: {
					Text("Cancel")
				}
				
			}
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
