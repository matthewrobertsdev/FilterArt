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
	@EnvironmentObject var imageViewModel: ImageViewModel
	@EnvironmentObject var modalStateViewModel: ModalStateViewModel
	@State private var image: Data = Data()
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
					MainImage(loading: $loading, renderedImage: $renderedImage).environmentObject(imageViewModel)
					Spacer(minLength: 0)
					InfoSeperator()
					GeometryReader { proxy in
						MainControls(proxy: proxy, loading: $loading, renderedImage: $renderedImage, thumbnailImage: $thumbnailImage, showingSuccessAlert: $showingSuccessAlert, showingErrorAlert: $showingErrorAlert).environmentObject(modalStateViewModel.environmentObject(imageViewModel)).frame(maxWidth: .infinity)
					}.frame(height: 215)
				}
				ImageDropReceiver().environmentObject(imageViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
				UnmodifiedImageSheet(imageDataStore: imageViewModel).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
				ModifiedImageSheet(renderedImage: $renderedImage).environmentObject(modalStateViewModel)
			}.onAppear() {
				if !useOriginalImage {
					ImageViewModel.load { result in
						switch result {
						case .failure(let error):
							print("failed: \(error)")
						case .success(let imageData):
							imageViewModel.imageData = imageData
						}
					}
				}
				storeSnapshot()
			}.sheet(isPresented: $modalStateViewModel.showingFilters) {
				FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageViewModel)
			}.onChange(of: imageViewModel.imageData) { imageData in
				ImageViewModel.save(imageData: imageViewModel.imageData) { result in
					
				}
			}.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
				NameAlert().environment(\.managedObjectContext, managedObjectContext).environmentObject(imageViewModel)
			}, message: {
				Text("Enter a name for your new filter:")
			})
#else
			VStack(spacing: 5) {
				VStack(spacing: 5) {
					Spacer(minLength: 0)
					MainImage(loading: $loading, renderedImage: $renderedImage).environmentObject(imageViewModel)
					Spacer(minLength: 0)
					InfoSeperator()
				}
				GeometryReader { proxy in
					ScrollView {
						MainControls(proxy: proxy, loading: $loading, renderedImage: $renderedImage, thumbnailImage: $thumbnailImage, showingSuccessAlert: $showingSuccessAlert, showingErrorAlert: $showingErrorAlert).environmentObject(modalStateViewModel).environmentObject(imageViewModel).frame(maxWidth: .infinity)
					}
				}.frame(height: 235)
			}
			.sheet(isPresented: $modalStateViewModel.showingShareSheet) {
				ShareSheet(image: imageViewModel.getFilteredImage())
			}.sheet(isPresented: $modalStateViewModel.showingPreviewModal) {
				ModifiedImageSheet(renderedImage: $renderedImage).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingUnmodifiedImage) {
				UnmodifiedImageSheet().environmentObject(imageViewModel).environmentObject(modalStateViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingFilters) {
				FiltersView(showing: $modalStateViewModel.showingFilters).environmentObject(imageViewModel)
			}.sheet(isPresented: $modalStateViewModel.showingImagePicker) {
				ImagePicker(imageData: $imageViewModel.imageData, useOriginalImage: $imageViewModel.useOriginalImage, loading: $loading)
			}.alert("Success!", isPresented: $modalStateViewModel.showingImageSaveSuccesAlert, actions: {
			}, message: {
				Text("Image saved to photo library.")
			}).alert("Whoops!", isPresented: $showingImageSaveFailureAlert, actions: {
			}, message: {
				Text("Could not save image.  Have you granted permisson in the Settings app under Privacy > Photos > Filter Art?")
			}).onAppear() {
				if !imageViewModel.useOriginalImage {
					ImageViewModel.load { result in
						switch result {
						case .failure:
							break
						case .success(let imageData):
							imageViewModel.imageData = imageData
							let filteredImage = resizeUIImage(image: UIImage(data: imageData) ?? UIImage())
							imageViewModel.imageData = filteredImage.pngData() ?? Data()
							thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: imageData) ?? UIImage()))
							renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
						}
					}
				} else {
					renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
					thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(named: "FallColors") ?? UIImage()))
				}
				imageViewModel.storeSnapshot()
			}.onChange(of: imageViewModel.imageData) { imageData in
				DispatchQueue.main.async {
					ImageViewModel.save(imageData: imageViewModel.imageData) { result in
						let filteredImage = resizeUIImage(image: UIImage(data: imageData) ?? UIImage())
						imageViewModel.imageData = filteredImage.pngData() ?? Data()
						thumbnailImage = Image(uiImage: resizeUIImageToThumbnail(image: UIImage(data: imageData) ?? UIImage()))
						renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
					}
				}
			}.alert("Name Your Filter", isPresented: $modalStateViewModel.showingNameAlert, actions: {
				NameAlert().environment(\.managedObjectContext, managedObjectContext).environmentObject(imageViewModel)
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
		}.onChange(of: imageViewModel.useHueRotation) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.hueRotation) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useContrast) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.contrast) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.invertColors) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useColorMultiply) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.colorMultiplyColor) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useSaturation) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.saturation) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useBrightness) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.brightness) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useGrayscale) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.grayscale) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useOpacity) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.opacity) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.useBlur) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}.onChange(of: imageViewModel.blur) { _ in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}
		.onReceive(NotificationCenter.default.publisher(for: .endEditing))
		{ notification in
			renderedImage = Image(uiImage: imageViewModel.getFilteredImage())
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#else
		.background(WindowAccessor(window: $window))
#endif
		.navigationTitle(Text("Filter Art"))
	}
	
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
