//
//  DefaultWeb3SocketClient.swift
//
//  Created by JeneaVranceanu on 14.12.2022.
//

import Foundation

#if !os(Linux)
public class DefaultWeb3SocketClient: Web3SocketClient {

    public let session = URLSession(configuration: .default)
    private let webSocketTask: URLSessionWebSocketTask
    private weak var delegate: Web3SocketDelegate?

    public private(set) var url: URL

    public init(url: URL) {
        self.url = url
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.delegate?.received(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.delegate?.received(text)
                case .data(let data):
                    self?.delegate?.received(data)
                @unknown default:
                    fatalError("New type of message was added by Apple into URLSessionWebSocketTask. Please, file an issue on https://github.com/web3swift-team/web3swift/issues. \(String(describing: message))")
                }
            }
        }
    }

    public func setDelegate(_ delegate: Web3SocketDelegate) {
        self.delegate = delegate
    }

    public func send(_ message: String) {
        webSocketTask.send(.string(message)) { error in
            if let error = error {
                self.delegate?.received(error)
            }
        }
    }

    public func send(_ message: Data) {
        webSocketTask.send(.data(message)) { error in
            if let error = error {
                self.delegate?.received(error)
            }
        }
    }

    public func resume() {
        if webSocketTask.state == .canceling ||
            webSocketTask.state == .completed ||
            webSocketTask.closeCode != .invalid { return }
        webSocketTask.resume()
    }

    public func cancel() {
        webSocketTask.cancel()
    }
}
#endif
