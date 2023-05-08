//
//  NumberFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import ComposableArchitecture
import SwiftUI

struct NumberFeature: Reducer {
    struct State: Equatable, Identifiable {
        var count = 0
        var fact = ""
        let id = UUID()
        var isRetrievingFact = false
        var isTimerOn = false
    }

    enum Action: Equatable {
        case decrementTapped
        case factResponse(TaskResult<String>)
        case incrementTapped
        case retrieveFactTapped
        case setTimer(Bool)
        case timerTick
    }

    private enum CancelID {
        case retrieveFact
        case timer
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.apiClient) var apiClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementTapped:
                guard !state.isRetrievingFact else {
                    return .none
                }
                state.count = max(state.count - 1, 0)
                return .none
            case let .factResponse(.success(response)):
                state.isRetrievingFact = false
                state.fact = response
                return .none
            case .factResponse(.failure):
                state.isRetrievingFact = false
                return .none
            case .incrementTapped:
                guard !state.isRetrievingFact else {
                    return .none
                }
                state.count += 1
                return .none
            case .retrieveFactTapped:
                state.isRetrievingFact = true
                let retrieveFact = Effect.run { [count =  state.count] send in
                    await send(NumberFeature.Action.factResponse(TaskResult { try await apiClient.retrieveNumberFact(count) } ))
                }
                .cancellable(id: CancelID.retrieveFact)
                state.isTimerOn = false
                return .merge(retrieveFact, .cancel(id: CancelID.retrieveFact), .cancel(id: CancelID.timer))
            case .setTimer(let isOn):
                state.isTimerOn = isOn
                if isOn {
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            case .timerTick:
                state.count += 1
                return .none
            }
        }
    }
}

struct NumberView: View {
    let store: StoreOf<NumberFeature>

    struct ViewState: Equatable {
        let count: Int
        let isRetrievingFact: Bool
        let isTimerOn: Bool
        let fact: String

        init(state: NumberFeature.State) {
            count = state.count
            isRetrievingFact = state.isRetrievingFact
            isTimerOn = state.isTimerOn
            fact = state.fact
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack {
                Toggle("Auto-increase counter", isOn: viewStore.binding(get: \.isTimerOn, send: NumberFeature.Action.setTimer))
                HStack {
                    Button {
                        viewStore.send(.decrementTapped)
                    } label: {
                        Text("-")
                    }
                    Text("\(viewStore.count)")
                    Button {
                        viewStore.send(.incrementTapped)
                    } label: {
                        Text("+")
                    }
                }
                .font(.system(size: 64))
                Button {
                    viewStore.send(.retrieveFactTapped)
                } label: {
                    Text("Retrieve Fact")
                }
                if viewStore.isRetrievingFact {
                    ProgressView()
                } else {
                    Text(viewStore.fact)
                }

            }
            .padding(.horizontal)
        }
    }
}

struct NumberView_Previews: PreviewProvider {
    static var previews: some View {
        NumberView(
            store: .init(
                initialState: .init(),
                reducer: NumberFeature()
            )
        )
    }
}
