//
//  ImageStore.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/13/22.
//

import Foundation
import SwiftUI

class ImageViewModel: ObservableObject {
	@Published var imageData: Data = Data()
	@Published var waitingForDrop = false
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
	@AppStorage(AppStorageKeys.imageUseOriginalImage.rawValue) private var useOriginalImage: Bool = true
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									   in: .userDomainMask,
									   appropriateFor: nil,
									   create: false)
			.appendingPathComponent("image.data")
	}
	
	static func exportURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									   in: .userDomainMask,
									   appropriateFor: nil,
									   create: false)
			.appendingPathComponent("Filter Art.png")
	}
	
	static func load(completion: @escaping (Result<Data, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let fileURL = try fileURL()
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					Task { @MainActor in
						completion(.success(Data()))
					}
					return
				}
				Task { @MainActor in
					completion(.success(file.availableData
					))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
	
	static func save(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let outfile = try fileURL()
				try imageData.write(to: outfile)
				Task { @MainActor in
					completion(.success(1))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
	
	static func saveForExport(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		Task(priority: .medium, operation: {
			do {
				let outfile = try exportURL()
				try imageData.write(to: outfile)
				Task { @MainActor in
					completion(.success(1))
				}
			} catch {
				Task { @MainActor in
					completion(.failure(error))
				}
			}
		})
	}
}

