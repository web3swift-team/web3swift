//
//  EIP4361.swift
//
//  Created by JeneaVranceanu at 19.09.2022.
//

import Foundation
import BigInt
import Core

public typealias SIWE = EIP4361

fileprivate let datetimePattern = "[0-9]{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(.[0-9]+)?(([Zz])|([+|-]([01][0-9]|2[0-3]):[0-5][0-9]))"
fileprivate let uriPattern = "(([^:?#]+):)?(([^?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"

/// Sign-In with Ethereum protocol and parser implementation.
/// EIP-4361: 
///    - https://eips.ethereum.org/EIPS/eip-4361
///    - https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4361.md
///
/// Thanks to spruceid for SIWE implementation that was rewritten here in Swift: https://github.com/spruceid/siwe/blob/main/packages/siwe-parser/lib/regex.ts
public final class EIP4361 {

    private static let domain = "(?<domain>([^?#]*)) wants you to sign in with your Ethereum account:"
    private static let address = "\\n(?<address>0x[a-zA-Z0-9]{40})\\n\\n"
    private static let statementParagraph = "((?<statement>[^\\n]+)\\n)?"
    private static let uri = "\\nURI: (?<uri>(\(uriPattern))?)"
    private static let version = "\\nVersion: (?<version>1)"
    private static let chainId = "\\nChain ID: (?<chainId>[0-9a-fA-F]+)"
    private static let nonce = "\\nNonce: (?<nonce>[a-zA-Z0-9]{8,})"
    private static let issuedAt = "\\nIssued At: (?<issuedAt>(\(datetimePattern)))"
    private static let expirationTime = "(\\nExpiration Time: (?<expirationTime>(\(datetimePattern))))?"
    private static let notBefore = "(\\nNot Before: (?<notBefore>(\(datetimePattern))))?"
    private static let requestId = "(\\nRequest ID: (?<requestId>[-._~!$&'()*+,;=:@%a-zA-Z0-9]*))?"
    private static let resourcesParagraph = "(\\nResources:(?<resources>(\\n- (\(uriPattern))?)+))?"

    private static var eip4361Pattern: String {
        "^\(domain)\(address)\(statementParagraph)\(uri)\(version)\(chainId)\(nonce)\(issuedAt)\(expirationTime)\(notBefore)\(requestId)\(resourcesParagraph)$"
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
        let eip4361Regex = try! NSRegularExpression(pattern: EIP4361.eip4361Pattern)
        let groups = eip4361Regex.captureGroups(string: message)
        let dateFormatter = ISO8601DateFormatter()

        guard let domain = groups["domain"],
              let rawAddress = groups["address"],
              let address = EthereumAddress(rawAddress),
              let rawUri = groups["uri"],
              let uri = URL(string: rawUri),
              let rawVersion = groups["version"],
              let version = BigUInt(rawVersion, radix: 10) ?? BigUInt(rawVersion, radix: 16),
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

