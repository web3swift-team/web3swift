//
//  Web3+WebsocketProvider.swift
//
//  Created by JeneaVranceanu on 14.12.2022.
//

import Core
import BigInt
import Foundation

/// A protocol for forwarding websocket messages.
public protocol Web3SocketMessageForwarder: AnyObject {
    /// Called when a websocket message is received. Potentially could be converted to `String` using
    /// `String(bytes: message, encoding: .utf8)`.
    /// - Parameter message: The message that was received.
    func received(_ message: Data)

    /// Called when an error occurs while receiving a websocket message.
    /// - Parameter error: The error that occurred.
    func received(_ error: Error)
}

/// A protocol for receiving websocket events from a Web3 client.
public protocol Web3SocketDelegate: AnyObject {
    /// Called when the websocket connection is established.
    func connected()

    /// Called when the websocket connection is closed.
    func disconnected()

    /// Called when a text message is received over the websocket connection.
    /// - Parameter message: The text message that was received.
    func received(_ message: String)

    /// Called when a binary message is received over the websocket connection.
    /// - Parameter message: The binary message that was received.
    func received(_ message: Data)

    /// Called when an error occurs while receiving a websocket message.
    /// - Parameter error: The error that occurred.
    func received(_ error: Error)
}

public class WebsocketSubscription: Subscription {
    public var id: String? = nil
    private let unsubscribeCallback: (WebsocketSubscription) -> Void

    public init(unsubscribeCallback: @escaping (WebsocketSubscription) -> Void) {
        self.unsubscribeCallback = unsubscribeCallback
    }

    public func unsubscribe() {
        unsubscribeCallback(self)
    }
}

public struct JSONRPCSubscriptionEvent<R: Decodable>: Decodable {
    public struct Params: Decodable {
        public let result: R
        public let subscription: String
    }

    public let method: String
    public let params: Params
}

/// A protocol to implement by the WebSocket client of your choice.
public protocol Web3SocketClient {
    /// URL of the WebSocket server
    var url: URL { get }
    /// Internal session used by this WebSocket client
    var session: URLSession { get }
    /// Send a message to the WebSocket server
    func send(_ message: String)
    /// Send a message to the WebSocket server
    func send(_ message: Data)
    /// Sets a delegate that send received responses back to the WebSocketProvider
    func setDelegate(_ delegate: Web3SocketDelegate)
    /// Resumes or starts the WebSocket connection
    func resume()
    /// Closes the WebSocket connection. Calling `resume` will have no effect after this call.
    func cancel()
}

/// The default websocket provider.
public class Web3SocketProvider: Web3SubscriptionProvider, Web3SocketDelegate {
    
    public var url: URL {
        web3SocketClient.url
    }
    public private(set) var network: Networks?
    public var policies: Policies = .auto
    public var keystoreManager: KeystoreManager?
    // TODO: Consider removing `public var session: URLSession` completely
    public var session: URLSession {
        web3SocketClient.session
    }

    public var web3SocketClient: Web3SocketClient
    public var forwarder: Web3SocketMessageForwarder?
    /// A flag that is true if socket connected or false if socket doesn't connected.
    public var websocketConnected: Bool = false
    /// Maintains a strong reference to subscriptions so that they could be reinitialized if a socket connection fails.
    /// Only the subscriptions previously successfully connected are added to the dictionary.
    /// The key is the subscription ID returned as the response from the server.
    private var subscriptions = [String: (sub: WebsocketSubscription, callback: (Swift.Result<Data, Error>) -> Void)]()
    /// One time requests where key is the ``JSONRPCRequest/id``.
    private var requests = [UInt: (Swift.Result<JSONRPCResponse, Error>) -> Void]()
    private var pendingRequests = [() -> Void]()
    /// Used to sync requests that are being tracked.
    private let internalQueue = DispatchQueue(label: "web3swift.websocketProvider.internalQueue",
                                              target: .global())

    public init?(_ web3SocketClient: Web3SocketClient,
                 network: Networks,
                 forwarder: Web3SocketMessageForwarder? = nil,
                 keystoreManager: KeystoreManager? = nil) {
        self.web3SocketClient = web3SocketClient
        self.network = network
        self.keystoreManager = keystoreManager
        web3SocketClient.setDelegate(self)
    }

    public convenience init?(_ endpoint: String,
                             forwarder: Web3SocketMessageForwarder? = nil) {
        guard let url = URL(string: endpoint) else { return nil }
        self.init(DefaultWeb3SocketClient(url: url), forwarder: forwarder)
    }

    public func subscribe<R>(filter: SubscribeEventFilter,
                             listener: @escaping Web3SubscriptionListener<R>) -> Subscription {
        internalQueue.sync {
            let subscription = WebsocketSubscription() { subscription in
                guard let id = subscription.id else {
                    return
                }
                let request = JSONRPCRequestFabric.prepareRequest(.unsubscribe, parameters: [id])
                self.sendAsync(request) { result in
                    switch result {
                    case .success(let response):
                        guard let unsubscribed: Bool = response.getValue() else {
                            listener(.failure(Web3Error.processingError(desc: "Wrong result in response: \(response)")))
                            return
                        }
                        if unsubscribed {
                            self.subscriptions.removeValue(forKey: id)
                            listener(.failure(Web3Error.processingError(desc: "Subscribtion with ID \(id) was cancelled (unsubscribed)")))
                        } else {
                            listener(.failure(Web3Error.processingError(desc: "Can\'t unsubscribe \(id)")))
                        }
                    case .failure(let error):
                        listener(.failure(error))
                    }
                }
            }

            let request = JSONRPCRequestFabric.prepareRequest(JSONRPCMethod.subscribe, parameters: filter.params)
            sendAsync(request) { result in
                switch result {
                case .success(let response):
                    guard let subscriptionID: String = response.getValue() else {
                        listener(.failure(Web3Error.processingError(desc: "Wrong result in response: \(response)")))
                        return
                    }
                    subscription.id = subscriptionID
                    self.subscriptions[subscriptionID] = (subscription, { result in
                        listener(result.flatMap { eventData in
                            Swift.Result {
                                try JSONDecoder().decode(JSONRPCSubscriptionEvent<R>.self, from: eventData)
                            }
                        }.map { $0.params.result })
                    })
                case .failure(let error):
                    listener(.failure(error))
                }
            }
            return subscription
        }
    }

    public func sendAsync(_ request: JSONRPCRequest,
                          _ callback: @escaping (Result<JSONRPCResponse, Error>) -> Void) {
        guard let method = request.method else {
            callback(.failure(Web3Error.inputError(desc: "No method in request: \(request)")))
            return
        }
        guard [.subscribe, .unsubscribe].contains(method) else {
            callback(.failure(Web3Error.inputError(desc: "Unsupported method: \(method)")))
            return
        }

        let requestData: Data
        do {
            requestData = try JSONEncoder().encode(request)
        } catch {
            callback(.failure(error))
            return
        }

        internalQueue.sync {
            self.requests[request.id] = { result in
                callback(result)
            }
            let writeRequest = { self.web3SocketClient.send(requestData) }
            if self.websocketConnected {
                writeRequest()
            } else {
                self.pendingRequests.append(writeRequest)
            }
        }
    }

    public func disconnected() {
        #warning("NOT IMPLEMENTED!!!")
        fatalError("NOT IMPLEMENTED!!!")
    }

    public func connectSocket() {
        web3SocketClient.resume()
    }

    public func disconnectSocket() {
        web3SocketClient.cancel()
    }

    public func isConnect() -> Bool {
        return websocketConnected
    }

    public func connected() {
        internalQueue.sync {
            pendingRequests.forEach { $0() }
            pendingRequests.removeAll()
        }
    }

    public func received(_ message: String) {
        guard let message = message.data(using: .utf8) else { return }
        received(message)
    }

    public func received(_ message: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: message, options: []) as? [String: Any]
        else { return }
        let messageAsString = String(describing: String(bytes: message, encoding: .utf8))
        if let _ = dictionary["id"] as? UInt64 {
            let response: JSONRPCResponse
            do {
                response = try JSONDecoder().decode(JSONRPCResponse.self, from: message)
            } catch {
                forwarder?.received(Web3Error.processingError(desc: "Cannot parse JSON-RPC response. Error: \(String(describing: error)). Response: \(messageAsString)"))
                return
            }
            internalQueue.sync {
                if let request = requests.removeValue(forKey: UInt(response.id)) {
                    if let error = response.error {
                        request(.failure(Web3Error.nodeError(desc: "Received an error message\n" + String(describing: error))))
                    } else {
                        request(.success(response))
                    }
                } else {
                    forwarder?.received(Web3Error.processingError(desc: "Unknown response id. Message is: \(messageAsString)"))
                }
            }
        } else if let params = dictionary["params"] as? [String: Any],
                  let subscriptionID = params["subscription"] as? String {
            guard let subscription = subscriptions[subscriptionID] else {
                forwarder?.received(Web3Error.processingError(desc: "Unknown subscription id: \(subscriptionID)"))
                return
            }
            subscription.callback(.success(message))
        } else {
            forwarder?.received(Web3Error.processingError(desc: "Can\'t get known result. Message is: \(messageAsString)"))
        }
    }

    public func received(_ error: Error) {
        forwarder?.received(Web3Error.processingError(desc: error.localizedDescription))
    }
}
