//
//  HueRotationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct HueRotationControl: View {
	@Binding private var hueRotation: Double
	init(hueRotation: Binding<Double>) {
		self._hueRotation = hueRotation
	}
    var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $hueRotation, in: 0...360)
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
