//
//  ColorStorage.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 8/20/22.
//
import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
extension Color: RawRepresentable {
	
#if canImport(UIKit)
typealias NativeColor = UIColor
#elseif canImport(AppKit)
typealias NativeColor = NSColor
#endif

	public init?(rawValue: String) {
		
		guard let data = Data(base64Encoded: rawValue) else{
			self = .blue
			return
		}
		
		do {
			let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NativeColor.self, from: data) ?? .blue
			self = Color(color)
		} catch{
			self = .blue
		}
		
		
	}

	public var rawValue: String {
		
		do{
			let data = try NSKeyedArchiver.archivedData(withRootObject: NativeColor(self), requiringSecureCoding: false) as Data
			return data.base64EncodedString()
			
		} catch{
			
			return ""
			
		}
		
	}

}
