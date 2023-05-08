//
//  StackNavFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 8/5/23.
//

import ComposableArchitecture
import SwiftUI

struct StackNavFeature: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case navigateToNumber
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .navigateToNumber:
                state.path.append(.number(.init()))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
          Path()
        }
    }

    struct Path: Reducer {
        enum State: Equatable {
            case item(ItemFeature.State)
            case number(NumberFeature.State)
        }
        enum Action: Equatable {
            case item(ItemFeature.Action)
            case number(NumberFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.number, action: /Action.number) {
                NumberFeature()
            }
            Scope(state: /State.item, action: /Action.item) {
                ItemFeature()
            }
        }
    }
}

struct StackNavView: View {
    let store: StoreOf<StackNavFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            VStack {
                Button {
                    ViewStore(store.stateless).send(.navigateToNumber)
                } label: {
                    Text("Go to number from button")
                }
                NavigationLink(state: StackNavFeature.Path.State.number(.init())) {
                  Text("Go to number from NavigationLink")
                }
                NavigationLink(state: StackNavFeature.Path.State.item(.init(item: .init(name: "Test")))) {
                  Text("Go to item from NavigationLink")
                }
            }
        } destination: { state in
            switch state {
            case .number:
              CaseLet(
                state: /StackNavFeature.Path.State.number,
                action: StackNavFeature.Path.Action.number,
                then: NumberView.init(store:)
              )
            case .item:
              CaseLet(
                state: /StackNavFeature.Path.State.item,
                action: StackNavFeature.Path.Action.item,
                then: ItemView.init(store:)
              )
            }
        }

    }
}

struct ThirdTab_Previews: PreviewProvider {
    static var previews: some View {
        StackNavView(
            store: .init(
                initialState: .init(),
                reducer: StackNavFeature()
            )
        )
    }
}
