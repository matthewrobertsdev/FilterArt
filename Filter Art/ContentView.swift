//
//  ContentView.swift
//  Fillter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@AppStorage("imageUseOriginalImage") private var useOriginalImage: Bool = true
    var body: some View {
		ImageView().navigationTitle(Text("Filter Art")).environmentObject(modalStateViewModel).environmentObject(filterStateHistory)
		
		#if os(macOS)
			.toolbar {
				ToolbarItemGroup(placement: .principal) {
					/*
					Button {
					} label: {
						Label("Choose Image", systemImage: "photo")
					}
					Button {
					} label: {
						Label("Filters", systemImage: "camera.filters")
					}
					Button {
					} label: {
						Label("Save Filter", systemImage: "plus")
					}
					Button {
					} label: {
						Label("Share", systemImage: "square.and.arrow.up")
					}
					Menu {
						Button {
						} label: {
							Text("Export")
						}
						Button {
						} label: {
							Text("Use Default Image")
						}
						Button {
						} label: {
							Text("View Original")
						}
					} label: {
						Label("More", systemImage: "ellipsis.circle")
					}
					*/
					/*
					Button {
						NotificationCenter.default.post(name: .showOpenPanel,
																		object: nil, userInfo: nil)
					} label: {
						Text("Choose Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingFilters = true
					} label: {
						Text("Filters...").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingNameAlert = true
					} label: {
						Text("Save Filter").labelStyle(.titleOnly)
					}
					Button {
						NotificationCenter.default.post(name: .showSavePanel,
																		object: nil, userInfo: nil)
					} label: {
						Text("Export...").labelStyle(.titleOnly)
					}
					Button {
						useOriginalImage = true
					} label: {
						Text("Use Default Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingUnmodifiedImage = true
					} label: {
						Text("View Original").labelStyle(.titleOnly)
					}
					 */
					/*
					Button {
						//showingNameAlert = true
					} label: {
						Label("Choose Image", systemImage: "photo")
					}
					Spacer()
					Button {
						//showingNameAlert = true
					} label: {
						Label("Add Saved Filter", systemImage: "plus")
					}
					Spacer()
					Button {
						//showingFilters = true
					} label: {
						Label("Apply Filter...", systemImage: "camera.filters")
					}
					Spacer()
					Button {
						//showingNameAlert = true
					} label: {
						Label("Export Image", systemImage: "square.and.arrow.down")
					}
					 */
					/*
					Button {
						//showingNameAlert = true
					} label: {
						Label("Share Image", systemImage: "square.and.arrow.up")
					}
					 */
				}
			}
		#endif
		
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

