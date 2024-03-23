//
//  MainControls.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI
import PhotosUI

struct MainControls: View {
	
	@State private var selectedItem: PhotosPickerItem? = nil
	@State private var editMode: ImageEditMode? = nil
	
	var proxy: GeometryProxy
	
	@Binding var loading: Bool
	@Binding var renderedImage: Image
	@Binding var thumbnailImage: Image
	@Binding var showingSuccessAlert: Bool
	@Binding var showingErrorAlert: Bool
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
		
	var body: some View {
		VStack(spacing: 10) {
#if os(iOS)
			HStack(spacing: 30) {
				PhotosPicker(selection:  $selectedItem, matching: .images)  {
					Label("Choose Image", systemImage: "photo").labelStyle(.titleOnly)
				}.onChange(of: selectedItem) { newItem in
					loading = true
					newItem?.loadTransferable(type: Data.self, completionHandler: { result in
						switch result  {
						case .success(let data):
							if let data = data {
								DispatchQueue.main.async {
									imageDataStore.imageData = data
									imageDataStore.useOriginalImage = false
									let filteredImage = resizeUIImage(image: UIImage(data: data) ?? UIImage())
									imageDataStore.imageData = filteredImage.pngData() ?? Data()
									thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: data) ?? UIImage()))
									renderedImage = Image(uiImage: imageDataStore.getFilteredImage())
								}
							}
						case .failure( _):
							break
						}
						loading = false
					})
				}
				Button {
					imageDataStore.thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: imageDataStore.imageData) ?? UIImage()))
					modalStateViewModel.showingFilters = true
				} label: {
					Label("Filters…", systemImage: "camera.filters").labelStyle(.titleOnly)
				}.controlSize(.regular)
			}
#else
			HStack(spacing: 15) {
				Button {
					NotificationCenter.default.post(name: .showOpenPanel,
													object: nil, userInfo: nil)
				} label: {
					Label("Choose Image", systemImage: "photo").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				Button {
					modalStateViewModel.showingFilters = true
				} label: {
					Label("Filters…", systemImage: "camera.filters").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				Button {
					modalStateViewModel.showingNameAlert = true
				} label: {
					Label("Save Filter", systemImage: "plus").labelStyle(.titleOnly)
				}.buttonStyle(.bordered).controlSize(.regular)
				ShareLink(item: Image(nsImage: getFilteredImage(forSharing: true)), preview: SharePreview(Text("Filtered Image"), image: Image(nsImage: getFilteredImage(forSharing: true)), icon: Image(nsImage: getFilteredImage(forSharing: true)))).labelStyle(.iconOnly).buttonStyle(.bordered).controlSize(.regular)
				Menu {
					Button {
						NotificationCenter.default.post(name: .showSavePanel,
														object: nil, userInfo: nil)
					} label: {
						Text("Export Image…").labelStyle(.titleOnly)
					}
					Button {
						useOriginalImage = true
					} label: {
						Text("Use Default Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingUnmodifiedImage = true
					} label: {
						Text("View Original Image").labelStyle(.titleOnly)
					}
				} label: {
					Label("More…", systemImage: "ellipsis.circle").labelStyle(.titleOnly)
				}.frame(width: 80).controlSize(.regular)
				
			}.padding(.top)
#endif
#if os(iOS)
			HStack(spacing: 30) {
				Button {
					modalStateViewModel.showingNameAlert = true
				} label: {
					Label("Save Filter", systemImage: "plus").labelStyle(.titleOnly)
				}.controlSize(.regular)
				Button {
					modalStateViewModel.showingShareSheet = true
				} label: {
					Label("Share Image", systemImage: "square.and.arrow.up")
				}.labelStyle(.iconOnly)
				Menu {
					Button {
						let imageSaver = ImageSaver(showingSuccessAlert: $showingSuccessAlert, showingErrorAlert: $showingErrorAlert)
						imageSaver.writeToPhotoAlbum(image: imageDataStore.getFilteredImage())
					} label: {
						Text("Save to Photos").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingUnmodifiedImage = true
					} label: {
						Text("View Original Image").labelStyle(.titleOnly)
					}
					Button {
						modalStateViewModel.showingPreviewModal = true
					} label: {
						Text("View Modified Image").labelStyle(.titleOnly)
					}
					Button {
						imageDataStore.useOriginalImage = true
					} label: {
						Text("Use Default Image").labelStyle(.titleOnly)
					}
				} label: {
					Label("More…", systemImage: "ellipsis.circle").labelStyle(.titleOnly)
				}.frame(width: 80).controlSize(.regular)
			}
			InfoSeperator()
#endif
			VStack {
				FilterControls(renderedImage: $renderedImage, proxy: proxy).environmentObject(imageDataStore)
			}
		}
#if os(macOS)
		
		.onReceive(NotificationCenter.default.publisher(for: .showOpenPanel))
		{ notification in
			showOpenPanel()
		}.onReceive(NotificationCenter.default.publisher(for: .showSavePanel))
		{ notification in
			showSavePanel()
		}
		.onReceive(NotificationCenter.default.publisher(for: .endEditing))
		{ notification in
			NSColorPanel.shared.close()
		}
#endif
		.onReceive(NotificationCenter.default.publisher(for: .undo))
		{ notification in
			print("abcd")
			imageDataStore.handleUndo()
		}.onReceive(NotificationCenter.default.publisher(for: .redo))
		{ notification in
			imageDataStore.handleRedo()
		}
	}
	
#if os(macOS)
	func getSavePanelButton() -> some View {
		Button {
			showSavePanel()
		} label: {
			Text("Export Image")
		}
	}
#endif
	
#if os(macOS)
	func showOpenPanel() {
		modalStateViewModel.showingOpenPanel = true
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Choose Photo"
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = false
		openPanel.canCreateDirectories = false
		openPanel.canChooseFiles = true
		openPanel.allowedContentTypes = [.image]
		if let window = window {
			openPanel.beginSheetModal(for: window) { result in
				if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
					if let url = openPanel.url {
						do {
							let imageData = try Data(contentsOf: url)
							var originalWidth = 1000.0
							var originalHeight = 1000.0
							var desiredWidth = 1000.0
							var desiredHeight = 1000.0
							if let fullSizeImage = NSImage(data: imageData) {
								originalWidth = fullSizeImage.size.width
								originalHeight = fullSizeImage.size.height
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
								let destSize = NSMakeSize(desiredWidth, desiredHeight)
								let newImage = NSImage(size: destSize)
								newImage.lockFocus()
								fullSizeImage.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, fullSizeImage.size.width, fullSizeImage.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
								newImage.unlockFocus()
								newImage.size = destSize
								if let newImageData = newImage.tiffRepresentation {
									imageDataStore.imageData = newImageData
									useOriginalImage = false
								}
							}
						} catch {
							print ("Error getting data from image file url.")
						}
					}
				}
				modalStateViewModel.showingOpenPanel = false
			}
		}
	}
	
	func showSavePanel() {
		modalStateViewModel.showingSavePanel = true
		let savePanel = NSSavePanel()
		savePanel.title = "Export Image"
		savePanel.prompt = "Export Image"
		savePanel.canCreateDirectories = false
		savePanel.allowedContentTypes = [.image]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M-d-y h.mm a"
		let dateString = dateFormatter.string(from: Date())
		savePanel.nameFieldStringValue = "Image \(dateString).png"
		if let window = window {
			savePanel.beginSheetModal(for: window) { result in
				if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
					if let url = savePanel.url {
						let imageRepresentation = NSBitmapImageRep(data: imageDataStore.getFilteredImage().tiffRepresentation ?? Data())
						let pngData = imageRepresentation?.representation(using: .png, properties: [:]) ?? Data()
						do {
							try pngData.write(to: url)
						} catch {
							print(error)
						}
					}
					
				} else {
					
				}
				modalStateViewModel.showingSavePanel = false
			}
		}
	}
#endif
}

/*
 #Preview {
 MainControls()
 }
 */
