//
//  RenameAlert.swift
//  Filter Art
//
//  Created by Matt Roberts on 1/22/23.
//

import SwiftUI

struct RenameAlert: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@State var renameString: String = ""
	@Binding var selectedSavedFilter: Filter?
    var body: some View {
		Group {
			TextField("Rename Text Field", text: $renameString, prompt: Text("Filter Name"))
			
			
			Button {
				DispatchQueue.main.async {
					if let filter = selectedSavedFilter {
						filter.name = renameString
						do {
							try managedObjectContext.save()
						} catch {
							
						}
					}
				}
			} label: {
				Text("Save")
			}.keyboardShortcut(.defaultAction)
			#if os(macOS)
			.disabled(renameString == "")
			#endif
			Button {
				
			} label: {
				Text("Cancel")
			}
		}

    }
}

/*
struct RenameAlert_Previews: PreviewProvider {
    static var previews: some View {
        RenameAlert()
    }
}
*/
