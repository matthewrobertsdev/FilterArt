//
//  ContentView.swift
//  Fillter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext

    var body: some View {
		ImageView().navigationTitle(Text("Filter Art"))
		/*
		#if os(macOS)
			.toolbar {
				ToolbarItemGroup(placement: .principal) {
					Button {
						//showingNameAlert = true
					} label: {
						Label("Add Saved Filter", systemImage: "plus")
					}
					Button {
						//showingFilters = true
					} label: {
						Label("Apply Filter...", systemImage: "camera.filters")
					}
					Button {
						//showingNameAlert = true
					} label: {
						Label("Export Image", systemImage: "square.and.arrow.down")
					}
					Button {
						//showingNameAlert = true
					} label: {
						Label("Share Image", systemImage: "square.and.arrow.up")
					}
				}
			}
		#endif
		 */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
