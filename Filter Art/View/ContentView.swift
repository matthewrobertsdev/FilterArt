//
//  ContentView.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/11/23.
//
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif
import Photos

struct ContentView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.managedObjectContext) var managedObjectContext
	@EnvironmentObject var filterStateHistory: FilterStateHistory
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@StateObject private var imageDataStore = ImageDataStore()
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
	@State private var image: Data = Data()
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
	@State var showingImageSaveFailureAlert = false
	@State var loading = false
	@State private var showingPhotoPicker: Bool = false
	@State private var showingErrorAlert: Bool = false
	@State private var showingSuccessAlert: Bool = false
	@State private var renderedImage = Image(uiImage: UIImage())
	@State private var thumbnailImage = Image(uiImage: UIImage())
#if os(macOS)
	@State private var window: NSWindow?
#endif
	init() {
	}
	var body: some View {
		Group {
#if os(macOS)
			ZStack {
				VStack(spacing: 5) {
					Spacer(minLength: 0)
					MainImage(loading: $loading, renderedImage: $renderedImage)
					Spacer(minLength: 0)
					InfoSeperator()
					GeometryReader { proxy in
						MainControls(loading: $loading, proxy: proxy, renderedImage: $renderedImage, thumbnailImage: $thumbnailImage, showingSuccessAlert: $showingSuccessAlert, showingErrorAlert: $showingErrorAlert).environmentObject(modalStateViewModel).frame(maxWidth: .infinity)
					}.frame(height: 215)
				}
				ImageDropReceiver().environmentObject(imageDataStore)
			}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
				UnmodifiedImageSheet(imageDataStore: imageDataStore).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
				ModifiedImageSheet(renderedImage: $renderedImage).environmentObject(modalStateViewModel)
			}.onAppear() {
				if !useOriginalImage {
					ImageDataStore.load { result in
						switch result {
						case .failure(let error):
							print("failed: \(error)")
						case .success(let imageData):
							imageDataStore.imageData = imageData
						}
					}
				}
				storeSnapshot()
			}.sheet(isPresented: $modalStateViewModel.showingFilters) {
				FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageDataStore)
					.environmentObject(filterStateHistory)
			}.onChange(of: imageDataStore.imageData) { imageData in
				ImageDataStore.save(imageData: imageDataStore.imageData) { result in
					
				}
			}.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
				NameAlert().environment(\.managedObjectContext, managedObjectContext)
			}, message: {
				Text("Enter a name for your new filter:")
			})
#else
			VStack(spacing: 5) {
				VStack(spacing: 5) {
					Spacer(minLength: 0)
					MainImage(loading: $loading, renderedImage: $renderedImage)
					Spacer(minLength: 0)
					InfoSeperator()
				}
				GeometryReader { proxy in
					ScrollView {
						MainControls(loading: $loading, proxy: proxy, renderedImage: $renderedImage, thumbnailImage: $thumbnailImage, showingSuccessAlert: $showingSuccessAlert, showingErrorAlert: $showingErrorAlert).environmentObject(modalStateViewModel).frame(maxWidth: .infinity)
					}
				}.frame(height: 235)
			}
			.sheet(isPresented: $modalStateViewModel.showingShareSheet) {
				ShareSheet(imageData: getFilteredImage(forSharing: true))
			}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
				ModifiedImageSheet(renderedImage: $renderedImage).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
				UnmodifiedImageSheet().environmentObject(imageDataStore).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingFilters) {
				FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageDataStore)
					.environmentObject(filterStateHistory)
			}.sheet(isPresented: $modalStateViewModel.showingImagePicker) {
				ImagePicker(imageData: $imageDataStore.imageData, useOriginalImage: $useOriginalImage, loading: $loading)
			}.alert("Success!", isPresented: $modalStateViewModel.showingImageSaveSuccesAlert, actions: {
			}, message: {
				Text("Image saved to photo library.")
			}).alert("Whoops!", isPresented: $showingImageSaveFailureAlert, actions: {
			}, message: {
				Text("Could not save image.  Have you granted permisson in the Settings app under Privacy > Photos > Filter Art?")
			}).onAppear() {
				if !useOriginalImage {
					ImageDataStore.load { result in
						switch result {
						case .failure:
							break
						case .success(let imageData):
							imageDataStore.imageData = imageData
							let filteredImage = resizeUIImage(image: UIImage(data: imageData) ?? UIImage())
							imageDataStore.imageData = filteredImage.pngData() ?? Data()
							thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: imageData) ?? UIImage()))
							renderedImage = Image(uiImage: getFilteredImage())
						}
					}
				} else {
					renderedImage = Image(uiImage: getFilteredImage())
					thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(named: "FallColors") ?? UIImage()))
				}
				storeSnapshot()
			}.onChange(of: imageDataStore.imageData) { imageData in
				DispatchQueue.main.async {
					ImageDataStore.save(imageData: imageDataStore.imageData) { result in
						let filteredImage = resizeUIImage(image: UIImage(data: imageData) ?? UIImage())
						imageDataStore.imageData = filteredImage.pngData() ?? Data()
						thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: imageData) ?? UIImage()))
						renderedImage = Image(uiImage: getFilteredImage())
					}
				}
			}.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
				NameAlert().environment(\.managedObjectContext, managedObjectContext)
			}, message: {
				Text("Enter a name for your new filter:")
			})
			.alert("Success!", isPresented: $showingSuccessAlert, actions: {
				Group {
					Button {
						showingSuccessAlert = false
					} label: {
						Text("Ok")
					}.keyboardShortcut(.defaultAction)

				}
			}, message: {
				Text("Saved to Photos.")
			})
			.alert("Oops! Failed to save to Photos.", isPresented: $showingErrorAlert, actions: {
				Group {
					Button {
						showingErrorAlert = false
					} label: {
						Text("Cancel")
					}
					Button {
						if let url = URL(string: UIApplication.openSettingsURLString) { if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)
							}
						}
						showingErrorAlert = false
					} label: {
						Text("Settings...")
					}

				}
			}, message: {
				Text("Have you allowed Filter Art to save to Photos in the Settings app?")
			})
#endif
		}
		.onReceive(NotificationCenter.default.publisher(for: .endEditing))
		{ notification in
			renderedImage = Image(uiImage: getFilteredImage())
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#else
		.background(WindowAccessor(window: $window))
#endif
		.navigationTitle(Text("Filter Art"))
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
	
	func storeSnapshot() {
		filterStateHistory.forUndo.append(FilterModel(blur: blur, brightness: brightness, colorMultiplyO: colorMultiplyColor.components.opacity, colorMultiplyB: colorMultiplyColor.components.blue, colorMultiplyG: colorMultiplyColor.components.green, colorMultiplyR: colorMultiplyColor.components.red, contrast: contrast, grayscale: grayscale, hueRotation: hueRotation, id: UUID().uuidString, invertColors: invertColors, opacity: opacity, name: "App State Filter", saturation: saturation, timestamp: Date(), useBlur: useBlur, useBrightness: useBrightness, useColorMultiply: useColorMultiply, useContrast: useContrast, useGrayscale: useGrayscale, useHueRotation: useHueRotation, useOpacity: useOpacity, useSaturation: useSaturation))
		filterStateHistory.forRedo = [FilterModel]()
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
		let renderer = ImageRenderer(content: getImage().resizable().aspectRatio(contentMode: .fit).if(forSharing, transform: { view in
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
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

enum ImageModal {
	case unmodified
	case preview
}

enum SheetType {
	case shareSheet
	case imagePicker
	case unmodifiedImage
	case modifiedImage
}
/*
#if os(macOS)
extension NSImage: Transferable {
	public static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(importedContentType: .image) { data in
			NSImage(data: data) ?? NSImage()
		}
	}
}
#endif
 */

enum ImageEditMode: String, CaseIterable {
	case hue
	case contrast
	case invert
	case colorMultiply = "Color Multiply"
	case saturation
	case brightness
	case grayscale
	case opacity
	case blur
}

struct ImageEditModeData {
	var mode: ImageEditMode
	var imageName: String
}

let imageEditModesData = [ImageEditModeData(mode: .hue, imageName: "paintbrush"),
						  ImageEditModeData(mode: .contrast, imageName: "circle.lefthalf.filled"),
						  ImageEditModeData(mode: .invert, imageName: "lightswitch.off"),
						  ImageEditModeData(mode: .colorMultiply, imageName: "paintpalette"),
						  ImageEditModeData(mode: .saturation, imageName: "sun.max"),
						  ImageEditModeData(mode: .brightness, imageName: "lightbulb"),
						  ImageEditModeData(mode: .grayscale, imageName: "circle.dotted"),
						  ImageEditModeData(mode: .opacity, imageName: "circle"),
						  ImageEditModeData(mode: .blur, imageName: "camera.filters")]

#if os(iOS)
func resizeUIImageToThumbnail(image: UIImage) -> UIImage {
	var originalWidth = 200.0
	var originalHeight = 200.0
	var desiredWidth = 1000.0
	var desiredHeight = 1000.0
		originalWidth = image.size.width
		originalHeight = image.size.height
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
		let newSize = CGSize(width: desiredWidth, height: desiredHeight)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
					image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
			UIGraphicsEndImageContext()
		return newImage
}
#endif
