//
//  PrintFilter.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/28/24.
//

import Foundation

func printFilter(filter: Filter) {
	var descriptionString = "Printing filter: "
	descriptionString += "name: \(filter.name ?? "unknown"), "
	descriptionString += "id: \(filter.id ?? "unknown"), "
	descriptionString += "isPreset: \(filter.isPreset), "
	descriptionString += "isFavorite: \(filter.isFavorite), "
	descriptionString += "invertColors: \(filter.invertColors), "
	descriptionString += "useHueRotation: \(filter.useHueRotation), "
	descriptionString += "hueRotation: \(filter.hueRotation), "
	descriptionString += "useContrast: \(filter.useContrast), "
	descriptionString += "contrast: \(filter.contrast), "
	descriptionString += "useColorMultiply: \(filter.useColorMultiply), "
	descriptionString += "colorMultiplyR: \(filter.colorMultiplyR), "
	descriptionString += "colorMultiplyG: \(filter.colorMultiplyG), "
	descriptionString += "colorMultiplyB: \(filter.colorMultiplyB), "
	descriptionString += "colorMultiplyO: \(filter.colorMultiplyO), "
	descriptionString += "useStauration: \(filter.useSaturation), "
	descriptionString += "saturation: \(filter.saturation), "
	descriptionString += "useGrayscale: \(filter.useGrayscale), "
	descriptionString += "useOpacity: \(filter.useOpacity), "
	descriptionString += "opcaity: \(filter.opacity), "
	descriptionString += "useBlur: \(filter.useBlur), "
	descriptionString += "blur: \(filter.blur), "
	print(descriptionString)
}
