//
//  OpacityControl.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

struct OpacityControl: View {
	@Binding private var opacity: Double
	var saveForUndo: () -> Void
	init(opacity: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._opacity = opacity
		self.saveForUndo = saveForUndo
	}
	var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $opacity, in: 0...1){ editing in
				if !editing {
					saveForUndo()
				}
			}
			Spacer()
			Text("\(1)")
		}
	}
}

/*
struct OpacityControl_Previews: PreviewProvider {
    static var previews: some View {
        OpacityControl()
    }
}
*/
