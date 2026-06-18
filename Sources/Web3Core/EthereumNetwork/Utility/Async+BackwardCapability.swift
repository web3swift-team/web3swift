//
//  Async+BackwardCapability.swift
//
//
//  Created by Yaroslav Yashin on 05.06.2022.
//

import Foundation

extension URLSession {
    func data(forHTTP request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        if #available(iOS 15.0, macOS 12.0, *) {
            let (data, response) = try await data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            return (data, response)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                dataTask.resume()
            }
        }
    }
}
