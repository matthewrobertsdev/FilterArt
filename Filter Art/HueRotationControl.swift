//
//  HueRotationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct HueRotationControl: View {
	@Binding private var useHueRotation: Bool
	@Binding private var hueRotation: Double
	init(useHueRotation: Binding<Bool>, hueRotation: Binding<Double>) {
		self._useHueRotation = useHueRotation
		self._hueRotation = hueRotation
	}
    var body: some View {
		HStack {
			Toggle("", isOn: $useHueRotation.animation()).toggleStyle(.switch).tint(Color.accentColor).frame(width: 50)
			Text("\(0)")
			Spacer()
			Slider(value: $hueRotation, in: 0...360).disabled(!useHueRotation)
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
