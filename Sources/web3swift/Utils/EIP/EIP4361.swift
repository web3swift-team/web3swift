//
//  EIP4361.swift
//
//  Created by JeneaVranceanu at 19.09.2022.
//

import Foundation
import BigInt
import Web3Core

public typealias SIWE = EIP4361

private let datetimePattern = "[0-9]{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(.[0-9]+)?(([Zz])|([+|-]([01][0-9]|2[0-3]):[0-5][0-9]))"
private let uriPattern = "(([^:?#\\s]+):)?(([^?#\\s]*))?([^?#\\s]*)(\\?([^#\\s]*))?(#(.*))?"

/// Sign-In with Ethereum protocol and parser implementation.
///
/// EIP-4361:
///    - https://eips.ethereum.org/EIPS/eip-4361
///    - https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4361.md
///
/// Thanks to spruceid for SIWE implementation that was rewritten here in Swift: https://github.com/spruceid/siwe/blob/main/packages/siwe-parser/lib/regex.ts
///
/// ## How to use?
///
/// The best approach on how to get an instance of `EIP4361` is by calling the function ``EIP4361/validate(_:)``
/// which in return gives you all the information you need for checking which SIWE attributes are missing or invalid,
/// and parsed `EIP4361` object itself if the raw message indeed was a SIWE message.
///
/// ```swift
/// let validationResponse = EIP4361.validate(rawStringMessage)
/// guard validationResponse.isEIP4361 else { return }
///
/// if validationResponse.isValid {
///    // Safe to force unwrap the `eip4361`
///    validationResponse.eip4361!
///    ...
/// } else {
///     // e.g. present user with an error message ...
///     // or
///     // use `validationResponse.parsedFields` to check which fields are missing or invalid
///     let isAddressValid = EthereumAddress(validationResponse[.address] ?? "") != nil
///     ...
/// }
/// ```
public final class EIP4361 {

    public enum EIP4361Field: String {
        case domain
        case address
        case statement
        case uri
        case version
        case chainId
        case nonce
        case issuedAt
        case expirationTime
        case notBefore
        case requestId
        case resources
    }

    private static let domain = "(?<\(EIP4361Field.domain.rawValue)>([^?#]*)) wants you to sign in with your Ethereum account:"
    private static let address = "\\n(?<\(EIP4361Field.address.rawValue)>0x[a-zA-Z0-9]{40})\\n\\n"
    private static let statementParagraph = "((?<\(EIP4361Field.statement.rawValue)>[^\\n]+)\\n)?"
    private static let uri = "\\nURI: (?<\(EIP4361Field.uri.rawValue)>(\(uriPattern))?)"
    private static let version = "\\nVersion: (?<\(EIP4361Field.version.rawValue)>[0-9]+)"
    private static let chainId = "\\nChain ID: (?<\(EIP4361Field.chainId.rawValue)>[0-9a-fA-F]+)"
    private static let nonce = "\\nNonce: (?<\(EIP4361Field.nonce.rawValue)>[a-zA-Z0-9]{8,})"
    private static let issuedAt = "\\nIssued At: (?<\(EIP4361Field.issuedAt.rawValue)>(\(datetimePattern)))"
    private static let expirationTime = "(\\nExpiration Time: (?<\(EIP4361Field.expirationTime.rawValue)>(\(datetimePattern))))?"
    private static let notBefore = "(\\nNot Before: (?<\(EIP4361Field.notBefore.rawValue)>(\(datetimePattern))))?"
    private static let requestId = "(\\nRequest ID: (?<\(EIP4361Field.requestId.rawValue)>[-._~!$&'()*+,;=:@%a-zA-Z0-9]*))?"
    private static let resourcesParagraph = "(\\nResources:(?<\(EIP4361Field.resources.rawValue)>(\\n- (\(uriPattern))?)+))?"

    private static var eip4361Pattern: String {
        "^\(domain)\(address)\(statementParagraph)\(uri)\(version)\(chainId)\(nonce)\(issuedAt)\(expirationTime)\(notBefore)\(requestId)\(resourcesParagraph)$"
    }

    private static var _eip4361OptionalPattern: String?
    private static var eip4361OptionalPattern: String {
        if let _eip4361OptionalPattern = _eip4361OptionalPattern { return _eip4361OptionalPattern }

        let domain = "(?<\(EIP4361Field.domain.rawValue)>(.*)) wants you to sign in with your Ethereum account:"
        let address = "\\n(?<\(EIP4361Field.address.rawValue)>.*)\\n\\n"
        let uri = "\\nURI: (?<\(EIP4361Field.uri.rawValue)>(.*)?)"
        let version = "\\nVersion: (?<\(EIP4361Field.version.rawValue)>.*)"
        let chainId = "\\nChain ID: (?<\(EIP4361Field.chainId.rawValue)>.*)"
        let nonce = "\\nNonce: (?<\(EIP4361Field.nonce.rawValue)>.*)"
        let issuedAt = "\\nIssued At: (?<\(EIP4361Field.issuedAt.rawValue)>(.*))"
        let expirationTime = "(\\nExpiration Time: (?<\(EIP4361Field.expirationTime.rawValue)>(.*)))?"
        let notBefore = "(\\nNot Before: (?<\(EIP4361Field.notBefore.rawValue)>(.*)))?"
        let requestId = "(\\nRequest ID: (?<\(EIP4361Field.requestId.rawValue)>.*))?"
        let resourcesParagraph = "(\\nResources:(?<\(EIP4361Field.resources.rawValue)>(.|\n)*))?"

        let patternParts: [String] = ["^\(domain)",
                                      "(\(address))?",
                                      "\(statementParagraph)",
                                      "(\(uri))?",
                                      "(\(version))?",
                                      "(\(chainId))?",
                                      "(\(nonce))?",
                                      "(\(issuedAt))?",
                                      "\(expirationTime)",
                                      "\(notBefore)",
                                      "\(requestId)",
                                      "\(resourcesParagraph)$"]

        let eip4361OptionalPattern = patternParts.joined()
        _eip4361OptionalPattern = eip4361OptionalPattern
        return eip4361OptionalPattern
    }

    public static func validate(_ message: String) -> EIP4361ValidationResponse {
        // swiftlint:disable force_try
        let siweConstantMessageRegex = try! NSRegularExpression(pattern: "^\(domain)\\n")
        guard siweConstantMessageRegex.firstMatch(in: message, range: message.fullNSRange) != nil else {
            return EIP4361ValidationResponse(isEIP4361: false, eip4361: nil, capturedFields: [:])
        }

        let eip4361Regex = try! NSRegularExpression(pattern: eip4361OptionalPattern)
        // swiftlint:enable force_try
        var capturedFields: [EIP4361Field: String] = [:]
        for (key, value) in eip4361Regex.captureGroups(string: message) {
            /// We are using EIP4361Field.rawValue to create regular expression.
            /// These values must decode back from raw representation always.
            // swiftlint:disable force_unwrapping
            capturedFields[.init(rawValue: key)!] = value
            // swiftlint:enable force_unwrapping
        }
        return EIP4361ValidationResponse(isEIP4361: true,
                                  eip4361: EIP4361(message),
                                         capturedFields: capturedFields)
    }

    /// `domain` is the RFC 3986 authority that is requesting the signing.
    public let domain: String
    /// `address` is the Ethereum address performing the signing conformant to capitalization encoded checksum specified in EIP-55 where applicable.
    public let address: EthereumAddress
    /// `statement` (optional) is a human-readable ASCII assertion that the user will sign, and it must not contain '\n' (the byte 0x0a).
    public let statement: String?
    /// `uri` is an RFC 3986 URI referring to the resource that is the subject of the signing (as in the subject of a claim).
    public let uri: URL
    /// `version` is the current version of the message, which MUST be 1 for this specification.
    public let version: BigUInt
    /// `chain-id` is the EIP-155 Chain ID to which the session is bound, and the network where Contract Accounts MUST be resolved.
    public let chainId: BigUInt
    /// `nonce` is a randomized token typically chosen by the relying party and used to prevent replay attacks, at least 8 alphanumeric characters.
    public let nonce: String
    /// `issued-at` is the ISO 8601 datetime string of the current time.
    public let issuedAt: Date
    /// `expiration-time` (optional) is the ISO 8601 datetime string that, if present, indicates when the signed authentication message is no longer valid.
    public let expirationTime: Date?
    /// `not-before` (optional) is the ISO 8601 datetime string that, if present, indicates when the signed authentication message will become valid.
    public let notBefore: Date?
    /// `request-id` (optional) is an system-specific identifier that may be used to uniquely refer to the sign-in request.
    public let requestId: String?
    /// `resources` (optional) is a list of information or references to information the user wishes to have resolved
    /// as part of authentication by the relying party. They are expressed as RFC 3986 URIs separated by "\n- " where \n is the byte 0x0a.
    public let resources: [URL]?

    public init?(_ message: String) {
        // swiftlint:disable force_try
        let eip4361Regex = try! NSRegularExpression(pattern: EIP4361.eip4361Pattern)
        // swiftlint:enable force_try
        let groups = eip4361Regex.captureGroups(string: message)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let domain = groups["domain"],
              let rawAddress = groups["address"],
              let address = EthereumAddress(rawAddress),
              let rawUri = groups["uri"],
              let uri = URL(string: rawUri),
              let rawVersion = groups["version"],
              let version = BigUInt(rawVersion, radix: 10) ?? BigUInt(rawVersion, radix: 16),
              version == 1,
              let rawChainId = groups["chainId"],
              let chainId = BigUInt(rawChainId, radix: 10) ?? BigUInt(rawChainId, radix: 16),
              let nonce = groups["nonce"],
              let rawIssuedAt = groups["issuedAt"],
              let issuedAt = dateFormatter.date(from: rawIssuedAt)
        else {
            return nil
        }

        self.domain = domain
        self.address = address
        self.statement = groups["statement"]
        self.uri = uri
        self.version = version
        self.chainId = chainId
        self.nonce = nonce
        self.issuedAt = issuedAt
        expirationTime = dateFormatter.date(from: groups["expirationTime"] ?? "")
        notBefore = dateFormatter.date(from: groups["notBefore"] ?? "")
        requestId = groups["requestId"]
        if let rawResources = groups["resources"] {
            resources = rawResources.components(separatedBy: "\n- ").compactMap { URL(string: $0) }
        } else {
            resources = nil
        }
    }

    public var description: String {
        var descriptionParts = [String]()
        descriptionParts.append("\(domain) wants you to sign in with your Ethereum account:")
        descriptionParts.append("\n\(address.address)")
        if let statement = statement {
            descriptionParts.append("\n\n\(statement)")
        }
        descriptionParts.append("\n\nURI: \(uri)")
        descriptionParts.append("\nVersion: \(version.description)")
        descriptionParts.append("\nChain ID: \(chainId.description)")
        descriptionParts.append("\nNonce: \(nonce)")
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        descriptionParts.append("\nIssued At: \(dateFormatter.string(from: issuedAt))")
        if let expirationTime = expirationTime {
            descriptionParts.append("\nExpiration Time: \(dateFormatter.string(from: expirationTime))")
        }
        if let notBefore = notBefore {
            descriptionParts.append("\nNot Before: \(dateFormatter.string(from: notBefore))")
        }
        if let requestId = requestId {
            descriptionParts.append("\nRequest ID: \(requestId)")
        }
        if let resources = resources, !resources.isEmpty {
            descriptionParts.append("\nResources:")
            descriptionParts.append(contentsOf: resources.map { "\n- \($0.absoluteString)" })
        }
        return descriptionParts.joined()
    }
}

/// A structure that holds the information about Sign In With Ethereum message and allows you to check
/// if the raw message is indeed a SIWE message, if it's a valid SIWE, which fields are present in the message
/// and if it's a valid message holds a reference to fully parsed ``EIP4361`` object.
public struct EIP4361ValidationResponse {
    public let isEIP4361: Bool
    public let eip4361: EIP4361?
    public let capturedFields: [EIP4361.EIP4361Field: String]

    public var isValid: Bool {
        eip4361 != nil
    }
}
