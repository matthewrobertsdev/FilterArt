//
//  ColorComponents.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 8/15/22.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
	var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

		#if canImport(UIKit)
		typealias NativeColor = UIColor
		#elseif canImport(AppKit)
		typealias NativeColor = NSColor
		#endif

		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var o: CGFloat = 0
		
		#if canImport(UIKit)
		NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
		#elseif canImport(AppKit)
		NativeColor(self).usingColorSpace(.extendedSRGB)?.getRed(&r, green: &g, blue: &b, alpha: &o)
		#endif
		return (r, g, b, o)
	}
}
