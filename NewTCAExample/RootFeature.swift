//
//  RootFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import ComposableArchitecture
import SwiftUI

struct RootFeature: Reducer {
    struct State: Equatable {
        var forEach = ForEachFeature.State()
        var navigation = NavigationFeature.State()
        var number = NumberFeature.State()
        var selectedTab = RootTab.number
        var stack = StackNavFeature.State()
    }

    enum Action: Equatable {
        case forEach(ForEachFeature.Action)
        case navigation(NavigationFeature.Action)
        case number(NumberFeature.Action)
        case selectedTab(RootTab)
        case stack(StackNavFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .navigation(.delegate(let navigationDelegate)):
                switch navigationDelegate {
                case .switchToNumberTab:
                    state.selectedTab = .number
                    return .none
                }
            case .navigation:
                return .none
            case .number:
                return .none
            case let .selectedTab(tab):
                state.selectedTab =  tab
                return .none
            case .stack:
                return .none
            case .forEach:
                return .none
            }
        }
        Scope(state: \.number, action: /Action.number) {
            NumberFeature()
        }
        Scope(state: \.navigation, action: /Action.navigation) {
            NavigationFeature()
        }
        Scope(state: \.stack, action: /Action.stack) {
            StackNavFeature()
        }
        Scope(state: \.forEach, action: /Action.forEach) {
            ForEachFeature()
        }
    }
}

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: RootFeature.Action.selectedTab)) {
                ForEach(RootTab.allCases, id: \.self) { tab  in
                    tab.view(for: store)
                        .tabItem {
                            Image(systemName: tab.systemNameImage)
                            Text(tab.rawValue)
                        }
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: .init(
            initialState: .init(),
            reducer: RootFeature())
        )
    }
}
