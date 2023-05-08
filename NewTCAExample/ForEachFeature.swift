//
//  ForthTabFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 10/5/23.
//

import ComposableArchitecture
import SwiftUI

struct ForEachFeature: Reducer {
    struct State: Equatable {
        var numbers: IdentifiedArrayOf<NumberFeature.State> = []

        init() {
            (0...8).forEach { _ in
                numbers.append(.init(count: 0))
            }

        }
    }

    enum Action: Equatable {
        case number(id: NumberFeature.State.ID, action: NumberFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            .none
        }
        .forEach(\.numbers, action: /Action.number) {
            NumberFeature()
        }
    }
}

struct ForEachExampleView: View {
    let store: StoreOf<ForEachFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ForEachStore(
                    store.scope(
                        state: \.numbers,
                        action: ForEachFeature.Action.number
                    ),
                    content: NumberView.init
                )

            }
        }
    }
}

struct ForthTab_Previews: PreviewProvider {
    static var previews: some View {
        ForEachExampleView(
            store: .init(
                initialState: .init(),
                reducer: ForEachFeature()
            )
        )
    }
}
