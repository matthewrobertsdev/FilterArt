//
//  Filter_ArtApp.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/13/23.
//

import SwiftUI

@main
struct Filter_ArtApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
				.frame(minWidth: 300, minHeight: 600)
#endif
        }
    }
}
