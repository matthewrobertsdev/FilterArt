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
	@State var selectedSavedFilter: Filter? = nil
	@State var isEditing = false
	@State var showingDeleteDialog = false
	@State var showingRenameAlert = false
	@State var filterToDelete: Filter? = nil
	@State var filterToRename: Filter? = nil
	
	init(showing: Binding<Bool>, searchString: String) {
		_showing = showing
		let searchStringPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
		let isNotPresetPredicate = NSPredicate(format: "isPreset == %@", NSNumber(value: false))
		let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [isNotPresetPredicate, searchStringPredicate])
		if searchString == "" {
			_savedFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: isNotPresetPredicate)
		} else {
			_savedFilters = FetchRequest<Filter>(sortDescriptors: [SortDescriptor(\.saveDate)], predicate: compoundPredicate)
		}
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
							getFilteredImage(filter: filter).frame(width: isEditing ? 175 : 250, height: 175).transition(.scale).transition(.move(edge: .leading))
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
				}.swipeActions(allowsFullSwipe: false) {
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
			}.onDelete(perform: delete)
		}.listStyle(.sidebar)
		#if os(iOS)
			.onChange(of: selectedSavedFilter) { newValue in
			asignSavedFilterComponentsToAppStorage()
			showing = false
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
			Text("Eenter a new name for your filter:")
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
				asignSavedFilterComponentsToAppStorage()
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
		if let filter = selectedSavedFilter {
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
