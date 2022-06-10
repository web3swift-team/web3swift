//
//  Async+BackwardCapability.swift
//  
//
//  Created by Yaroslav Yashin on 05.06.2022.
//

import Foundation

@available(iOS, obsoleted: 15.0, message: "Use the built-in API instead")
@available(macOS, obsoleted: 12.0, message: "Use the built-in API instead")
extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?

        return try await withCheckedThrowingContinuation { continuation in
            dataTask = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            dataTask?.resume()
        }
    }
}
