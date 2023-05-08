//
//  NewTCAExampleTests.swift
//  NewTCAExampleTests
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//
@testable import NewTCAExample

import ComposableArchitecture
import XCTest

@MainActor
final class NewTCAExampleTests: XCTestCase {
    func testFirstTab() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: NumberFeature()
        )

        await store.send(.incrementTapped) {
            $0.count = 1
        }


        await store.send(.decrementTapped) {
            $0.count = 0
        }
    }
}
