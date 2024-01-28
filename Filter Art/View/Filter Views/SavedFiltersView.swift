//
//  SavedFiltersView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/23.
//

import SwiftUI

struct SavedFiltersView: View {
	
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@FetchRequest(sortDescriptors: [SortDescriptor(\.saveDate)]) var savedFilters: FetchedResults<Filter>
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	
	@Binding var showing: Bool
	
	@State var selectedSavedFilter: Filter? = nil
	@State var isEditing = false
	@State var showingDeleteDialog = false
	@State var showingRenameAlert = false
	@State var filterToDelete: Filter? = nil
	@State var filterToRename: Filter? = nil
	
	var image: Image = Image(uiImage: UIImage())
	
	init(showing: Binding<Bool>, searchString: String, thumbnailData: Data) {
		_showing = showing
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
		let isNotPresetPredicate = NSPredicate(format: "isPreset == %@", NSNumber(value: false))
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isNotPresetPredicate, searchStringPredicate])
		if searchString == "" {
			_savedFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: isNotPresetPredicate)
		} else {
			_savedFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
		image = Image(uiImage: UIImage(data: thumbnailData) ?? UIImage())
		
	}
	
	var body: some View {
		List(selection: $selectedSavedFilter) {
			ForEach(savedFilters, id: \.self) { filter in
				VStack(alignment: .center) {
						HStack {
							if isEditing {
								VStack(spacing: 20) {
									Button(role: .destructive) {
										filterToDelete = filter
										showingDeleteDialog = true
									} label: {
										Label("Delete", systemImage: "trash.fill").labelStyle(.titleOnly)
									}.buttonStyle(.borderless).tint(Color.red)
									Button {
										filterToRename = filter
										showingRenameAlert = true
									} label: {
										Label("Rename", systemImage: "pencil").labelStyle(.titleOnly)
									}.buttonStyle(.borderless).tint(Color.indigo)
								}.transition(.move(edge: .leading))

							}
							Spacer()
							imageDataStore.getFilteredImage(filter: filter).resizable().aspectRatio(contentMode: .fit)
							#if os(macOS)
								.frame(width: isEditing ? 175 : 250, height: 175)
							#else
								.frame(width: isEditing ? 175 : 250, height: 175)
							#endif
								.transition(.scale).transition(.move(edge: .leading))
							Spacer()
						}
					HStack {
						Spacer()
						Text(filter.name ?? "Saved Filter")
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
					}.frame(maxWidth: 300)
					Spacer()
				}/*.swipeActions(allowsFullSwipe: false) {
					Button(role: .destructive) {
						filterToDelete = filter
						showingDeleteDialog = true
					} label: {
						Label("Delete", systemImage: "trash.fill").labelStyle(.iconOnly)
					}
					Button {
						filterToRename = filter
						showingRenameAlert = true
					} label: {
						Label("Rename", systemImage: "pencil").labelStyle(.iconOnly)
					}.tint(.indigo)
					
				}
				  */
			}//.onDelete(perform: delete)
		}.listStyle(.sidebar)
		#if os(iOS)
			.onChange(of: selectedSavedFilter) { newValue in
				imageDataStore.asignSavedFilterComponentsToAppStorage(selectedSavedFilter: selectedSavedFilter)
				imageDataStore.storeSnapshot()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					NotificationCenter.default.post(name: .endEditing,
																	object: nil, userInfo: nil)
					showing = false
				}
		}
		#endif
			.confirmationDialog(Text("Are you sure you want to delete this filter?"), isPresented: $showingDeleteDialog) {
			Button(role: .destructive) {
				DispatchQueue.main.async {
					if let filter = filterToDelete {
						managedObjectContext.delete(filter)
						selectedSavedFilter = nil
						do {
							try managedObjectContext.save()
						} catch {
							
						}
					}
				}
			} label: {
				Text("Delete Filter")
			}
		}.alert("Rename Your Filter", isPresented: $showingRenameAlert, actions: {
			RenameAlert(selectedSavedFilter: $filterToRename).environment(\.managedObjectContext, managedObjectContext)
		}, message: {
			Text("Enter a new name for your filter:")
		})
		#if os(macOS)
		.toolbar(content: {
			Button {
				showing = false
			} label: {
				Text("Cancel")
			}
			Button(role: .destructive) {
				filterToDelete = selectedSavedFilter
				showingDeleteDialog = true
			} label: {
				Text("Delete")
			}.disabled(selectedSavedFilter == nil)
			Button {
				filterToRename = selectedSavedFilter
				showingRenameAlert = true
			} label: {
				Text("Rename")
			}.disabled(selectedSavedFilter == nil)
			Button {
				NotificationCenter.default.post(name: .endEditing,
																object: nil, userInfo: nil)
				asignSavedFilterComponentsToAppStorage()
				imageViewModel.storeSnapshot()
				showing = false
			} label: {
				Text("Apply Filter")
			}.disabled(selectedSavedFilter == nil).keyboardShortcut(.defaultAction)
			
		})
		#else
		.toolbar {
			ToolbarItem(placement: .navigation, content: {
				Button {
					if isEditing {
						do {
							try managedObjectContext.save()
						} catch {
							
						}
					}
					withAnimation {
						isEditing.toggle()
					}
				} label: {
					Text(isEditing ? "Done" : "Edit")
				}
			})
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
	
	func delete(filter: Filter) {
		do {
			managedObjectContext.delete(filter)
			selectedSavedFilter = nil
			try managedObjectContext.save()
		} catch {
			
		}
	}
	
	func delete(at offsets: IndexSet) {
		for index in offsets {
			do {
				managedObjectContext.delete(savedFilters[index])
				try managedObjectContext.save()
			} catch {
				
			}
		}
	}

}

/*
 struct SavedFiltersView_Previews: PreviewProvider {
 static var previews: some View {
 SavedFiltersView()
 }
 }
 */
