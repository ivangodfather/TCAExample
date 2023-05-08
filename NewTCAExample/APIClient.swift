//
//  APIClient.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 15/5/23.
//

import Dependencies
import Foundation

struct APIClient {
    var retrieveNumberFact: (Int) async throws -> String
}

extension APIClient: DependencyKey {
    static let liveValue =  APIClient { num in
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
        let data = try await  URLSession.shared.data(from: URL(string: "http://numberapi.com/\(num)/trivia")!).0
        return String(data: data, encoding: .utf8)!
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
