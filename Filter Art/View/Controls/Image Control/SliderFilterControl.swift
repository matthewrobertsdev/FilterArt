//
//  SliderFilterControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 5/6/23.
//

import SwiftUI

struct SliderFilterControl: View {
	@Binding private var value: Double
	var saveForUndo: () -> Void
	var min: Int
	var max: Int
	init(value: Binding<Double>, saveForUndo: @escaping () -> Void, min: Int, max: Int) {
		self._value = value
		self.saveForUndo = saveForUndo
		self.min = min
		self.max = max
	}
	var body: some View {
		HStack {
			Text("\(min)")
			Spacer()
			Slider(value: $value, in: Double(min)...Double(max)) { editing in
				if !editing {
					saveForUndo()
				}
			}
			Spacer()
			Text("\(max)")
		}
	}
}

/*
struct SliderFilterControl_Previews: PreviewProvider {
    static var previews: some View {
        SliderFilterControl()
    }
}
*/
