//
//  ImageStore.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/13/22.
//

import Foundation

class ImageDataStore: ObservableObject {
	@Published var imageData: Data = Data()
	
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
		DispatchQueue.global(qos: .background).async {
			do {
				let fileURL = try fileURL()
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					DispatchQueue.main.async {
						completion(.success(Data()))
					}
					return
				}
				DispatchQueue.main.async {
					completion(.success(file.availableData
									   ))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	static func save(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		DispatchQueue.global(qos: .default).async {
			do {
				let outfile = try fileURL()
				try imageData.write(to: outfile)
				DispatchQueue.main.async {
					completion(.success(1))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	static func saveForExport(imageData: Data, completion: @escaping (Result<Int, Error>)->Void) {
		DispatchQueue.global(qos: .default).async {
			do {
				let outfile = try exportURL()
				try imageData.write(to: outfile)
				DispatchQueue.main.async {
					completion(.success(1))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
}

