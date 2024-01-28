//
//  MainImage.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/27/24.
//

import SwiftUI

struct MainImage: View {
	
	@Binding var loading: Bool
	
	@Binding var renderedImage: Image
	
	@EnvironmentObject var imageDataStore: ImageViewModel
	
    var body: some View {
		Group {
			if loading {
				VStack {
					Text("Loading Image…")
					ProgressView().controlSize(.large)
				}
			} else {
				renderedImage.resizable().aspectRatio(contentMode: .fit)
#if os(macOS)
				.onDrag {
					imageDataStore.getImageNSItemProvider()
				}
#endif
			}
		}
    }
	
}

/*
#Preview {
    MainImage()
}
*/
