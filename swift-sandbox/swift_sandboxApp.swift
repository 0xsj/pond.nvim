//
//  swift_sandboxApp.swift
//  swift-sandbox
//

import SwiftUI

@main
struct swift_sandboxApp: App {
    @State private var appStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: appStore)
                .preferredColorScheme(appStore.colorScheme)
        }
    }
}
