//
//  FilterModel.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/17/23.
//

import Foundation

struct FilterModel: Identifiable, Hashable {
	var blur: Double
	var colorMultiplyA: Double
	var colorMultiplyB: Double
	var colorMultiplyG: Double
	var colorMultiplyR: Double
	var contrast: Double
	var grayscale: Double
	var hueRotation: Double
	var id: Int16
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


let originalFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 0, grayscale: 0, hueRotation: 0, id: 1, invertColors: false, opacity: 1, name: "Original", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let vibrantFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1.2, grayscale: 0, hueRotation: 0, id: 2, invertColors: false, opacity: 1, name: "Vibrant", saturation: 1.5, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: true)

let grayscale = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 0, grayscale: 1, hueRotation: 0, id: 3, invertColors: false, opacity: 1, name: "Grayscale", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: true, useHueRotation: false, useOpacity: false, useSaturation: false)

let wild1 = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.4, colorMultiplyG: 0.8, colorMultiplyR: 1, contrast: 1.2, grayscale: 0, hueRotation: 180, id: 4, invertColors: false, opacity: 1, name: "Wild #1", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)

let wild2 = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.7, colorMultiplyG: 0.8, colorMultiplyR: 0.3, contrast: 1.2, grayscale: 0, hueRotation: 180, id: 5, invertColors: false, opacity: 1, name: "Wild #2", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)

let inverted = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 0, id: 6, invertColors: true, opacity: 1, name: "Inverted", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let invertedWild = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 0, id: 7, invertColors: true, opacity: 1, name: "Inverted Wild", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: true)

let invertedWild2 = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 1, grayscale: 0, hueRotation: 150, id: 8, invertColors: true, opacity: 1, name: "Inverted Wild #2", saturation: 10, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: true, useOpacity: false, useSaturation: true)

let redFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.2, colorMultiplyG: 0.2, colorMultiplyR: 0.8, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 9, invertColors: false, opacity: 1, name: "Red Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let orangeFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.2, colorMultiplyG: 0.4, colorMultiplyR: 0.8, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 10, invertColors: false, opacity: 1, name: "Orange Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let yellowFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.3, colorMultiplyG: 0.8, colorMultiplyR: 1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 11, invertColors: false, opacity: 1, name: "Yellow Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let greenFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 0.5, colorMultiplyG: 1, colorMultiplyR: 0.4, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 12, invertColors: false, opacity: 1, name: "Green Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let blueFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 0.8, colorMultiplyR: 0.1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 13, invertColors: false, opacity: 1, name: "Blue Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let indigoFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 0.4, colorMultiplyR: 0.3, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 15, invertColors: false, opacity: 1, name: "Indigo Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let purpleFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 0.3, colorMultiplyR: 0.6, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 16, invertColors: false, opacity: 1, name: "Purple Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let pinkFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 0.3, colorMultiplyR: 1, contrast: 1.5, grayscale: 0, hueRotation: 0, id: 17, invertColors: false, opacity: 1, name: "Pink Tint", saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: true, useContrast: true, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)

let presetFilters = [
	originalFilter,
	vibrantFilter,
	grayscale,
	wild1,
	wild2,
	inverted,
	invertedWild,
	invertedWild2,
	redFilter,
	orangeFilter,
	yellowFilter,
	greenFilter,
	blueFilter,
	indigoFilter,
	purpleFilter,
	pinkFilter
]
