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
	@Binding var loading: Bool
	var proxy: GeometryProxy
	@Binding var renderedImage: Image
	@Binding var thumbnailImage: Image
	@Binding var showingSuccessAlert: Bool
	@Binding var showingErrorAlert: Bool
	@EnvironmentObject var imageDataStore: ImageDataStore
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
	@AppStorage(AppStorageKeys.imageInvertColors.rawValue) private var invertColors: Bool = false
	@AppStorage(AppStorageKeys.imageHueRotation.rawValue) private var hueRotation: Double = 0
	@AppStorage(AppStorageKeys.imageUseHueRotation.rawValue) private var useHueRotation: Bool = true
	@AppStorage(AppStorageKeys.imageContrast.rawValue) private var contrast: Double = 1
	@AppStorage(AppStorageKeys.imageUseContrast.rawValue) private var useContrast: Bool = true
	@AppStorage(AppStorageKeys.imageUseColorMultiply.rawValue) private var useColorMultiply: Bool = true
	@AppStorage(AppStorageKeys.imageColorMultiplyColor.rawValue) private var colorMultiplyColor: Color = Color.white
	@AppStorage(AppStorageKeys.imageUseSaturation.rawValue) private var useSaturation: Bool = true
	@AppStorage(AppStorageKeys.imageSaturation.rawValue) private var saturation: Double = 1
	@AppStorage(AppStorageKeys.imageUseBrightness.rawValue) private var useBrightness: Bool = true
	@AppStorage(AppStorageKeys.imageBrightness.rawValue) private var brightness: Double = 0
	@AppStorage(AppStorageKeys.imageUseGrayscale.rawValue) private var useGrayscale: Bool = true
	@AppStorage(AppStorageKeys.imageGrayscale.rawValue) private var grayscale: Double = 0
	@AppStorage(AppStorageKeys.imageUseOpacity.rawValue) private var useOpacity: Bool = true
	@AppStorage(AppStorageKeys.imageOpacity.rawValue) private var opacity: Double = 1
	@AppStorage(AppStorageKeys.imageUseBlur.rawValue) private var useBlur: Bool = true
	@AppStorage(AppStorageKeys.imageBlur.rawValue) private var blur: Double = 0
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
									useOriginalImage = false
									let filteredImage = resizeUIImage(image: UIImage(data: data) ?? UIImage())
									imageDataStore.imageData = filteredImage.pngData() ?? Data()
									thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: data) ?? UIImage()))
									renderedImage = Image(uiImage: getFilteredImage())
								}
							}
						case .failure( _):
							break
						}
						loading = false
					})
				}
				Button {
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
						imageSaver.writeToPhotoAlbum(image: getFilteredImage())
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
						useOriginalImage = true
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
				FilterControls(renderedImage: $renderedImage, proxy: proxy).environmentObject(filterStateHistory).environmentObject(imageDataStore)
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
			handleUndo()
		}.onReceive(NotificationCenter.default.publisher(for: .redo))
		{ notification in
			handleRedo()
		}
	}
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
	}
	
	func handleUndo() {
		restoreSnapshot(stateToRestore: filterStateHistory.undo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
	func handleRedo() {
		restoreSnapshot(stateToRestore: filterStateHistory.redo())
		Task {
			try? await Task.sleep(nanoseconds: 1000_000_000)
			filterStateHistory.isModifying = false
		}
	}
	
	func restoreSnapshot(stateToRestore: FilterModel?) {
		if let stateToRestore = stateToRestore {
			invertColors = stateToRestore.invertColors
			hueRotation = stateToRestore.hueRotation
			useHueRotation = stateToRestore.useHueRotation
			contrast = stateToRestore.contrast
			brightness = stateToRestore.brightness
			useBrightness = stateToRestore.useBrightness
			useContrast = stateToRestore.useContrast
			useColorMultiply = stateToRestore.useColorMultiply
			colorMultiplyColor = Color(red: stateToRestore.colorMultiplyR, green: stateToRestore.colorMultiplyG, blue: stateToRestore.colorMultiplyB, opacity: stateToRestore.colorMultiplyO)
			useSaturation = stateToRestore.useSaturation
			saturation = stateToRestore.saturation
			useGrayscale = stateToRestore.useGrayscale
			grayscale = stateToRestore.grayscale
			useOpacity = stateToRestore.useOpacity
			opacity = stateToRestore.opacity
			useBlur = stateToRestore.useOpacity
			blur = stateToRestore.blur
		}
	}
	
	func resetAll() {
			invertColors = originalFilter.invertColors
			hueRotation = originalFilter.hueRotation
			useHueRotation = originalFilter.useHueRotation
			contrast = originalFilter.contrast
			brightness = originalFilter.brightness
			useBrightness = originalFilter.useBrightness
			useContrast = originalFilter.useContrast
			useColorMultiply = originalFilter.useColorMultiply
			colorMultiplyColor = Color(red: originalFilter.colorMultiplyR, green: originalFilter.colorMultiplyG, blue: originalFilter.colorMultiplyB, opacity: originalFilter.colorMultiplyO)
			useSaturation = originalFilter.useSaturation
			saturation = originalFilter.saturation
			useGrayscale = originalFilter.useGrayscale
			grayscale = originalFilter.grayscale
			useOpacity = originalFilter.useOpacity
			opacity = originalFilter.opacity
			useBlur = originalFilter.useOpacity
			blur = originalFilter.blur
	}
	
	
#if os(iOS)
	@MainActor func getFilteredImage(forSharing: Bool = false) -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		if useOriginalImage {
			desiredWidth = 750.0
			desiredHeight = 1000.0
		} else {
			let uiImage = (UIImage(data: imageDataStore.imageData)  ?? UIImage())
			originalWidth = uiImage.size.width
			originalHeight = uiImage.size.height
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
		let renderer = ImageRenderer(content:  getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
			view.frame(width: desiredWidth, height: desiredHeight)
		})
			.if(useHueRotation, transform: { view in
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
		
		if let uiImage = renderer.uiImage {
			print("01/22/2024 success")
			return uiImage
		}
		return UIImage(named: "FallColors") ?? UIImage()
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
						let imageRepresentation = NSBitmapImageRep(data: getFilteredImage().tiffRepresentation ?? Data())
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

#if os(iOS)
	func resizeUIImage(image: UIImage) -> UIImage {
		var originalWidth = 1000.0
		var originalHeight = 1000.0
		var desiredWidth = 1000.0
		var desiredHeight = 1000.0
		originalWidth = image.size.width
		originalHeight = image.size.height
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
		let newSize = CGSize(width: desiredWidth, height: desiredHeight)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
		UIGraphicsEndImageContext()
		return newImage
	}
#endif
