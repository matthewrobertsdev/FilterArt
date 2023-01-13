//
//  SaturationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct SaturationControl: View {
	@Binding private var saturation: Double
	init(saturation: Binding<Double>) {
		self._saturation = saturation
	}
	var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $saturation, in: 0...50)
			Spacer()
			Text("\(50)")
		}
	}
}

/*
struct SaturationControl_Previews: PreviewProvider {
    static var previews: some View {
        SaturationControl()
    }
}
*/
