//
//  FilterModel.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/17/23.
//

import Foundation

struct FilterModel: Identifiable, Hashable {
	var blur: Double
	var colorMultiplyO: Double
	var colorMultiplyB: Double
	var colorMultiplyG: Double
	var colorMultiplyR: Double
	var contrast: Double
	var grayscale: Double
	var hueRotation: Double
	var id: String
	var invertColors: Bool
	var opacity: Double
	var name: String
	var saturation: Double
	var timestamp: Date
	var useBlur: Bool
	var useColorMultiply: Bool
	var useContrast: Bool
	var useGrayscale: Bool
	var useHueRotation: Bool
	var useOpacity: Bool
	var useSaturation: Bool
}

let originalFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 0, id: "original", invertColors: false, opacity: 1, name: "Original", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let yellowGreenSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: -0.28, colorMultiplyG: 0.76, colorMultiplyR: 1.04, contrast: 1.45, grayscale: 0, hueRotation: 181.57, id: "yellowGreenSaturated", invertColors: false, opacity: 1, name: "Yellow-Green Saturated", saturation: 6.59, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let yellowSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: -0.28, colorMultiplyG: 0.76, colorMultiplyR: 1.04, contrast: 1.57, grayscale: 0, hueRotation: 47.45, id: "yellowSaturated", invertColors: false, opacity: 1, name: "Yellow Saturated", saturation: 3.77, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let orangeSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: -0.28, colorMultiplyG: 0.76, colorMultiplyR: 1.04, contrast: 1.59, grayscale: 0, hueRotation: 213.17, id: "orangeSaturated", invertColors: false, opacity: 1, name: "Orange Saturated", saturation: 3.81, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: false, useSaturation: true)

let blueFlorescent = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 0.48, colorMultiplyR: 0.50, contrast: 1.38, grayscale: 0, hueRotation: 0, id: "blueFlorescent", invertColors: false, opacity: 1, name: "Blue Florescent", saturation: 3.62, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: false, useSaturation: true)

let blueAndBlack = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1.04, colorMultiplyG: 0, colorMultiplyR: 0, contrast: 1.57, grayscale: 0, hueRotation: 0, id: "blueAndBlack", invertColors: false, opacity: 1, name: "Blue and Black", saturation: 1.54, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: false, useSaturation: true)

let redAndBlack = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.08, colorMultiplyG: 0.12, colorMultiplyR: 0.33, contrast: 1.61, grayscale: 0, hueRotation: 0, id: "redAndBlack", invertColors: false, opacity: 1, name: "Red and Black", saturation: 3.84, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let blueAndRedSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1.03, colorMultiplyG: 0.58, colorMultiplyR: -0.28, contrast: 1.57, grayscale: 0, hueRotation: 181.84, id: "blueAndRedSaturated", invertColors: false, opacity: 1, name: "Blue and Red Saturated", saturation: 4.72, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let greenSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: -0.31, colorMultiplyG: 1.02, colorMultiplyR: -0.36, contrast: 1.57, grayscale: 0, hueRotation: 181.84, id: "greenSaturated", invertColors: false, opacity: 1, name: "Green Saturated", saturation: 1.95, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let pinkSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1.04, colorMultiplyG: 0.11, colorMultiplyR: 0.63, contrast: 1.57, grayscale: 0, hueRotation: 210.53, id: "pinkSaturated", invertColors: false, opacity: 1, name: "Pink Saturated", saturation: 2.54, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let rainbowSaturated = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.58, colorMultiplyG: 1.00, colorMultiplyR: 0.96, contrast: 1.57, grayscale: 0, hueRotation: 210.53, id: "rainbowSaturated", invertColors: false, opacity: 1, name: "Rainbow Saturated", saturation: 4.46, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: false, useSaturation: true)

/*
let invertedWildNumber1 = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 0, id: "invertedWildNumber1", invertColors: true, opacity: 1, name: "Inverted Wild #1", saturation: 3.85, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: true)

let invertedWildNumber2 = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 150, id: "invertedWildNumber2", invertColors: true, opacity: 1, name: "Inverted Wild #2", saturation: 3.10, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)
*/

let contrastFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 2.0, grayscale: 0, hueRotation: 0, id: "contrast", invertColors: false, opacity: 1, name: "Contrast", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let vibrantFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1.2, grayscale: 0, hueRotation: 0, id: "vibrant", invertColors: false, opacity: 1, name: "Vibrant", saturation: 1.5, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let redFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.2, colorMultiplyG: 0.2, colorMultiplyR: 0.8, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "redTint", invertColors: false, opacity: 1, name: "Red Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let orangeFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.2, colorMultiplyG: 0.4, colorMultiplyR: 0.8, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "orangeTint", invertColors: false, opacity: 1, name: "Orange Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let yellowFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.3, colorMultiplyG: 0.8, colorMultiplyR: 1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "yellowTint", invertColors: false, opacity: 1, name: "Yellow Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let greenFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.5, colorMultiplyG: 1, colorMultiplyR: 0.4, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "greenTint", invertColors: false, opacity: 1, name: "Green Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let blueFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 0.8, colorMultiplyR: 0.1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "blueTint", invertColors: false, opacity: 1, name: "Blue Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let indigoFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.85, colorMultiplyG: 0.4, colorMultiplyR: 0.3, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "indigoTint", invertColors: false, opacity: 1, name: "Indigo Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let purpleFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 0.3, colorMultiplyR: 0.6, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "purpleTint", invertColors: false, opacity: 1, name: "Purple Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let pinkFilter = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 0.3, colorMultiplyR: 1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: "pinkTint", invertColors: false, opacity: 1, name: "Pink Tint", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let grayscale = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 1, hueRotation: 0, id: "grayscale", invertColors: false, opacity: 1, name: "Grayscale", saturation: 1, timestamp: Date(), useBlur: true, useColorMultiply: true, useContrast: true, useGrayscale: true, useHueRotation: true, useOpacity: true, useSaturation: true)

let presetFilters = [
	originalFilter,
	yellowGreenSaturated,
	yellowSaturated,
	orangeSaturated,
	blueFlorescent,
	blueAndBlack,
	redAndBlack,
	blueAndRedSaturated,
	greenSaturated,
	pinkSaturated,
	rainbowSaturated,
	vibrantFilter,
	contrastFilter,
	redFilter,
	orangeFilter,
	yellowFilter,
	greenFilter,
	blueFilter,
	indigoFilter,
	purpleFilter,
	pinkFilter,
	grayscale
]

/*
 let blueAndGreen = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.7, colorMultiplyG: 0.8, colorMultiplyR: 0.3, contrast: 1.2, grayscale: 0, hueRotation: 180, id: "blueAndGreen", invertColors: false, opacity: 1, name: "Blue and Green", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)
 */

/*
let inverted = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 0, id: 6, invertColors: true, opacity: 1, name: "Inverted", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)
*/

/*
let wild1 = FilterModel(blur: 0, colorMultiplyO: 1, colorMultiplyB: 0.4, colorMultiplyG: 0.8, colorMultiplyR: 1, contrast: 1.2, grayscale: 0, hueRotation: 180, id: 4, invertColors: false, opacity: 1, name: "Wild #1", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)
*/
