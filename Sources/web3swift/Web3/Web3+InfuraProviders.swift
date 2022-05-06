//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import Starscream

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net: Networks, accessToken token: String? = nil) {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token ?? Constants.infuraToken
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net)
    }
}

/// Custom Websocket provider of Infura nodes.
public final class InfuraWebsocketProvider: WebsocketProvider {
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
            || network == Networks.Mainnet else {return nil}
        let networkName = network.name
        var urlString = "wss://" + networkName + Constants.infuraWsScheme
        urlString += projectId ?? Constants.infuraToken
        guard let url = URL(string: urlString) else {return nil}
        super.init(url, delegate: delegate, network: network)
    }

    public init?(_ endpoint: String,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        var endpoint = endpoint
        if !(endpoint.hasPrefix("wss://") || endpoint.hasPrefix("ws://")) {
            return nil
        }
        var network: Networks? = nil
        if endpoint.hasPrefix("wss://") && endpoint.hasSuffix(Constants.infuraWsScheme) {
            let networkString = endpoint.replacingOccurrences(of: "wss://", with: "")
                .replacingOccurrences(of: Constants.infuraWsScheme, with: "")
            switch networkString {
            case "mainnet":
                network = Networks.Mainnet
            case "rinkeby":
                network = Networks.Rinkeby
            case "ropsten":
                network = Networks.Ropsten
            case "kovan":
                network = Networks.Kovan
            default:
                break
            }
        }
        guard let network = network else {
            return nil
        }
        endpoint += projectId ?? Constants.infuraToken
        guard let url = URL(string: endpoint) else {return nil}
        super.init(url, delegate: delegate, network: network)
    }

    public convenience init?(_ endpoint: URL,
                             delegate: Web3SocketDelegate? = nil,
                             projectId: String? = nil) {
        self.init(endpoint.absoluteString, delegate: delegate, projectId: projectId)
    }

    public class func connectToSocket(_ endpoint: String,
                                      delegate: Web3SocketDelegate? = nil,
                                      projectId: String? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }

    public class func connectToSocket(_ endpoint: URL,
                                      delegate: Web3SocketDelegate? = nil,
                                      projectId: String? = nil,
                                      network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }

    public static func connectToInfuraSocket(_ network: Networks,
                                             delegate: Web3SocketDelegate,
                                             projectId: String? = nil) -> InfuraWebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(network,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
}
