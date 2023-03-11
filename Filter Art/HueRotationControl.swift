//
//  HueRotationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct HueRotationControl: View {
	@Binding private var hueRotation: Double
	var saveForUndo: () -> Void
	init(hueRotation: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._hueRotation = hueRotation
		self.saveForUndo = saveForUndo
	}
    var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $hueRotation, in: 0...360) { editing in
				if !editing {
					saveForUndo()
				}
			}
			Spacer()
			Text("\(360)")
		}
    }
}

/*
struct HueRotationControl_Previews: PreviewProvider {
    static var previews: some View {
        HueRotationControl()
    }
}
*/
