//
//  FilterModel.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/17/23.
//

import Foundation

struct FilterModel {
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


let originalFilter = FilterModel(blur: 0, colorMultiplyA: 1, colorMultiplyB: 1, colorMultiplyG: 1, colorMultiplyR: 1, contrast: 0, grayscale: 0, hueRotation: 0, id: 1, invertColors: false, opacity: 1, saturation: 0, timestamp: Date(), useBlur: false, useColorMultiply: false, useContrast: false, useGrayscale: false, useHueRotation: false, useOpacity: false, useSaturation: false)
