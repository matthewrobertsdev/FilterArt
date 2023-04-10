//
//  BrightnessControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 3/11/23.
//

import Foundation

import SwiftUI

struct BrightnessControl: View {
	@Binding private var brightness: Double
	var saveForUndo: () -> Void
	init(brightness: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._brightness = brightness
		self.saveForUndo = saveForUndo
	}
	var body: some View {
		HStack {
			Text("\(-2)")
			Spacer()
			Slider(value: $brightness, in: -2...2){ editing in
				if !editing {
					saveForUndo()
				}
			}
			Spacer()
			Text("\(2)")
		}
	}
}


/*
struct BrightnessControl_Previews: PreviewProvider {
	static var previews: some View {
		BrightnessControl()
	}
}
*/

