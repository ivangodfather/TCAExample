//
//  NewTCAExampleApp.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import SwiftUI

@main
struct NewTCAExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialState: .init(), reducer: RootFeature()))
        }
    }
}
