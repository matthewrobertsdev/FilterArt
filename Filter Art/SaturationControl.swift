//
//  SaturationControl.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/12/22.
//

import SwiftUI

struct SaturationControl: View {
	@Binding private var saturation: Double
	var saveForUndo: () -> Void
	init(saturation: Binding<Double>, saveForUndo: @escaping () -> Void) {
		self._saturation = saturation
		self.saveForUndo = saveForUndo
	}
	var body: some View {
		HStack {
			Text("\(0)")
			Spacer()
			Slider(value: $saturation, in: 0...50){ editing in
				if !editing {
					saveForUndo()
				}
			}
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
