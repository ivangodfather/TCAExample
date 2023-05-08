//
//  RootTab.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 23/5/23.
//

import ComposableArchitecture
import SwiftUI

enum RootTab: String, CaseIterable {
    case number
    case navigation
    case stack
    case forEach

    var systemNameImage: String {
        switch self {
        case .number:
            return "textformat.123"
        case .navigation:
            return "figure.sailing"
        case .stack:
            return "square.stack.3d.down.forward"
        case .forEach:
            return "arrow.2.squarepath"
        }

    }

    @ViewBuilder
    func view(for store: StoreOf<RootFeature>) -> some View {
        switch self {
        case .number:
            NumberView(
                store: store.scope(
                    state: \.number,
                    action: RootFeature.Action.number
                )
            )
            .tag(self)
        case .navigation:
            NavigationExampleView(
                store: store.scope(
                    state: \.navigation,
                    action: RootFeature.Action.navigation
                )
            )
            .tag(self)
        case .stack:
            StackNavView(
                store: store.scope(
                    state: \.stack,
                    action: RootFeature.Action.stack
                )
            )
            .tag(self)
        case .forEach:
            ForEachExampleView(
                store: store.scope(
                    state: \.forEach,
                    action: RootFeature.Action.forEach
                )
            )
            .tag(self)
        }
    }
}
