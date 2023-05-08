//
//  NavigationFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import ComposableArchitecture
import SwiftUI

struct NavigationFeature: Reducer {
    struct State: Equatable {
        let item = Item(name: "Pencil")
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case closeSheetButtonTapped
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case showItemAsFullScreenCover(Item)
        case showItemAsNavigation(Item)
        case showItemAsSheet(Item)
        case showConfirmationDialogTapped
        case showHelloAlertTapped
        case showWarningAlertTapped
        case switchToNumberTabTapped

        enum Alert: Equatable {
            case reset
        }

        enum Dialog: Equatable {
            case confirmation
            case reset
        }

        enum Delegate: Equatable {
            case switchToNumberTab
        }
    }

    struct Destination: Reducer {
        enum State: Equatable {
            case alert(AlertState<NavigationFeature.Action.Alert>)
            case dialog(ConfirmationDialogState<NavigationFeature.Action.Dialog>)
            case itemAsFullScreenCover(ItemFeature.State)
            case itemAsNavigation(ItemFeature.State)
            case itemAsSheet(ItemFeature.State)
        }

        enum Action: Equatable {
            case alert(NavigationFeature.Action.Alert)
            case dialog(NavigationFeature.Action.Dialog)
            case itemAsFullScreenCover(ItemFeature.Action)
            case itemAsNavigation(ItemFeature.Action)
            case itemAsSheet(ItemFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.itemAsSheet, action: /Action.itemAsSheet) {
                ItemFeature()
            }
            Scope(state: /State.itemAsNavigation, action: /Action.itemAsNavigation) {
                ItemFeature()
            }
            Scope(state: /State.itemAsFullScreenCover, action: /Action.itemAsNavigation) {
                ItemFeature()
            }
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeSheetButtonTapped:
                state.destination = nil
                return .none
            case .delegate:
                return .none
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .destination(.presented(.alert(.reset))), .destination(.presented(.dialog(.reset))):
                print("reset!")
                return .none
            case .destination:
                return .none
            case .showItemAsFullScreenCover(let item):
                state.destination = .itemAsFullScreenCover(.init(item: item))
                return .none
            case .showItemAsNavigation(let item):
                state.destination = .itemAsNavigation(.init(item: item))
                return .none
            case .showItemAsSheet(let item):
                state.destination = .itemAsSheet(.init(item: item))
                return .none
            case .showConfirmationDialogTapped:
                state.destination = .dialog(.confirmationDialog())
                return .none
            case .showHelloAlertTapped:
                state.destination = .alert(.helloAlert())
                return .none
            case .showWarningAlertTapped:
                state.destination = .alert(.warningAlert())
                return .none
            case .switchToNumberTabTapped:
                return .send(.delegate(.switchToNumberTab))
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension AlertState where Action == NavigationFeature.Action.Alert {
    static func helloAlert() -> Self {
        AlertState {
            TextState("Hello 🤗")
        } actions: {
            ButtonState {
                TextState("Ok")
            }
        } message: {
            TextState("Hello hello!")
        }
    }

    static func warningAlert() -> Self {
        AlertState {
            TextState("Warning ❗️")
        } actions: {
            ButtonState(role: .destructive, action: .send(.reset, animation: .default)) {
                TextState("Reset")
            }
        } message: {
            TextState("is this a warning?")
        }
    }
}

extension ConfirmationDialogState where Action == NavigationFeature.Action.Dialog {
    static func confirmationDialog() -> Self {
        ConfirmationDialogState {
            TextState("This is a title")
        } actions: {
            ButtonState(action: .send(.reset, animation: .default)) {
                TextState("Reset")
            }
        } message: {
            TextState("Are you sure you want to reset?")
        }
    }
}

struct NavigationExampleView: View {
    let store: StoreOf<NavigationFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(store, observe: \.item) { viewStore in
                VStack(spacing: 16) {
                    Button {
                        viewStore.send(.showHelloAlertTapped)
                    } label: {
                        Text("Hello alert")
                    }
                    Button {
                        viewStore.send(.showWarningAlertTapped)
                    } label: {
                        Text("Warning alert")
                    }
                    Button {
                        viewStore.send(.showConfirmationDialogTapped)
                    } label: {
                        Text("Confirmation dialog")
                    }
                    Button {
                        viewStore.send(.showItemAsNavigation(viewStore.state))
                    } label: {
                        Text("Item as link")
                    }
                    Button {
                        viewStore.send(.showItemAsFullScreenCover(viewStore.state))
                    } label: {
                        Text("Item as full screen cover")
                    }
                    Button {
                        viewStore.send(.showItemAsSheet(viewStore.state))
                    } label: {
                        Text("Item as sheet")
                    }
                    Button {
                        ViewStore(store.stateless).send(.switchToNumberTabTapped)
                    } label: {
                        Text("Switch to 123number tab")
                    }
                }
                .alert(
                    store: self.store.scope(
                        state: \.$destination,
                        action: NavigationFeature.Action.destination
                    ),
                    state: /NavigationFeature.Destination.State.alert,
                    action: NavigationFeature.Destination.Action.alert
                )
                .confirmationDialog(
                    store: store.scope(
                        state: \.$destination,
                        action: NavigationFeature.Action.destination
                    ),
                    state: /NavigationFeature.Destination.State.dialog,
                    action: NavigationFeature.Destination.Action.dialog
                )
                .navigationDestination(
                    store: store.scope(state: \.$destination, action: NavigationFeature.Action.destination),
                    state: /NavigationFeature.Destination.State.itemAsNavigation,
                    action: NavigationFeature.Destination.Action.itemAsNavigation,
                    destination: ItemView.init
                )
                .sheet(
                    store: store.scope(state: \.$destination, action: NavigationFeature.Action.destination),
                    state: /NavigationFeature.Destination.State.itemAsSheet,
                    action: NavigationFeature.Destination.Action.itemAsSheet
                ) { store in
                    NavigationStack {
                        ItemView(store: store)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button {
                                        viewStore.send(.closeSheetButtonTapped)
                                    } label: {
                                        Text("Close")
                                    }
                                }
                            }
                    }
                }
                .fullScreenCover(
                    store: store.scope(state: \.$destination, action: NavigationFeature.Action.destination),
                    state: /NavigationFeature.Destination.State.itemAsFullScreenCover,
                    action: NavigationFeature.Destination.Action.itemAsFullScreenCover
                ) { store in
                    NavigationStack {
                        ItemView(store: store)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button {
                                        viewStore.send(.closeSheetButtonTapped)
                                    } label: {
                                        Text("Close")
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}

struct NavigationExampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationExampleView(
            store: .init(initialState: .init(), reducer: NavigationFeature())
        )
    }
}
