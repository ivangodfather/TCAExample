//
//  ItemFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 9/5/23.
//

import ComposableArchitecture
import SwiftUI

struct Item: Identifiable, Equatable {
    let id: UUID
    let name: String
    var count: Int

    init(name: String) {
        id = UUID()
        self.name = name
        count = 0
    }
}

extension Array where Element == Item {
    static let mock: [Item] = [
        .init(name: "red"),
        .init(name: "green"),
        .init(name: "blue"),
    ]
}

struct ItemFeature: Reducer {
    struct State: Equatable, Identifiable {
        var item: Item

        var id: UUID {
            item.id
        }
    }

    enum Action: Equatable {
        case viewTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewTapped:
                state.item.count += 1
                return .none
            }
        }
    }
}


struct ItemView: View {
    let store: StoreOf<ItemFeature>

    var body: some View {
        WithViewStore(store, observe: \.item) { viewStore in
            VStack {
                Text(viewStore.id.uuidString)
                Text(viewStore.name)
                Text(viewStore.count.description)
            }
            .onTapGesture {
                viewStore.send(.viewTapped)
            }
        }
    }
}

struct ItemFeature_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(store: .init(
            initialState: .init(item: [Item].mock[0]),
            reducer: ItemFeature())
        )
    }
}
