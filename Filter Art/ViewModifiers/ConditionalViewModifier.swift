//
//  ConditionalViewModifier.swift
//  SwiftUI Design
//
//  Created by Matt Roberts on 9/5/22.
//

import SwiftUI

extension View {
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}
