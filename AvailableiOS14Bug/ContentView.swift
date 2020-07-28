//
//  ContentView.swift
//  AvailableiOS14Bug
//
//  Created by Jeremy Gale on 2020-07-28.
//

import SwiftUI

struct NormalCaseHeader: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.textCase(nil)
        } else {
            content
        }
    }

    // This works on iOS 14 but doesn't compile in Xcode 11.6 for iOS 13. Error:
    // Value of type 'NormalCaseHeader.Content' (aka '_ViewModifier_Content<NormalCaseHeader>') has no member 'textCase'
//    func body(content: Content) -> some View {
//        if #available(iOS 14, *) {
//            return AnyView(content.textCase(nil))
//        } else {
//            return AnyView(content)
//        }
//    }
}

extension View {
    func normalCase() -> some View {
        return self.modifier(NormalCaseHeader())
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("lowercase text")) {
                    Text("Item 1")
                    Text("Item 2")
                }
                .normalCase()
            }
            .navigationBarTitle("#if available bug")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
