//
//  Web3Error.swift
//
//
//  Created by Yaroslav Yashin on 11.07.2022.
//

import Foundation

public enum Web3Error: LocalizedError {
    case transactionSerializationError(desc: String? = nil)
    case connectionError(desc: String? = nil)

    case dataError(desc: String? = nil)
    case typeError(desc: String? = nil)
    case valueError(desc: String? = nil)
    case serverError(code: Int)
    case clientError(code: Int)

    case walletError(desc: String? = nil)
    case inputError(desc: String)
    case nodeError(desc: String)
    case processingError(desc: String)
    case keystoreError(err: AbstractKeystoreError)
    case generalError(err: Error)
    case unknownError(desc: String? = nil, err: Error? = nil)

    public var errorDescription: String? {
        switch self {
        case .transactionSerializationError(let desc):
            return "Transaction Serialization Error. Description: \(desc ?? "-")."
        case .connectionError(let desc):
            return "Connection Error. Description: \(desc ?? "-")."
        case .dataError(let desc):
            return "Data Error. Description: \(desc ?? "-")."
        case .walletError(let desc):
            return "Wallet Error. Description: \(desc ?? "-")."
        case .inputError(let desc):
            return desc
        case .nodeError(let desc):
            return desc
        case .processingError(let desc):
            return desc
        case .keystoreError(let err):
            return err.localizedDescription
        case .generalError(let err):
            return err.localizedDescription
        case let .unknownError(desc, err):
            return "Unknown Error. Description: \(desc ?? "-"); Error thrown: \(err?.localizedDescription ?? "-")."
        case .typeError(let desc):
            return "Unsupported type. Description: \(desc ?? "-")."
        case let .serverError(code: code):
            return "Server error: \(code)"
        case let .clientError(code: code):
            return "Client error: \(code)"
        case .valueError(let errorDescription):
            return (errorDescription?.isEmpty ?? true) ? "You're passing value that isn't supported by this method" : errorDescription!
        }
    }
}
