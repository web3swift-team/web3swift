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
/// _Regular expressions were generated using ABNF grammar from https://github.com/spruceid/siwe/blob/main/packages/siwe-parser/lib/abnf.ts#L5
/// and tool https://pypi.org/project/abnf-to-regexp/ that outputs Python supported regular expressions._
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

    private static let unreserved = "[a-zA-Z0-9\\-._~]"
    private static let pctEncoded = "%[0-9A-Fa-f][0-9A-Fa-f]"
    private static let subDelims = "[!$&'()*+,;=]"
    private static let userinfo = "(\(unreserved)|\(pctEncoded)|\(subDelims)|:)*"
    private static let h16 = "[0-9A-Fa-f]{1,4}"
    private static let decOctet = "([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
    private static let ipv4address = "\(decOctet)\\.\(decOctet)\\.\(decOctet)\\.\(decOctet)"
    private static let ls32 = "(\(h16):\(h16)|\(ipv4address))"
    private static let ipv6address = "((\(h16):){6}\(ls32)|::(\(h16):){5}\(ls32)|(\(h16))?::(\(h16):){4}\(ls32)|((\(h16):)?\(h16))?::(\(h16):){3}\(ls32)|((\(h16):){2}\(h16))?::(\(h16):){2}\(ls32)|((\(h16):){3}\(h16))?::\(h16):\(ls32)|((\(h16):){4}\(h16))?::\(ls32)|((\(h16):){5}\(h16))?::\(h16)|((\(h16):){6}\(h16))?::)"
    private static let ipvfuture = "[vV][0-9A-Fa-f]+\\.(\(unreserved)|\(subDelims)|:)+"
    private static let ipLiteral = "\\[(\(ipv6address)|\(ipvfuture))\\]"
    private static let regName = "(\(unreserved)|\(pctEncoded)|\(subDelims))*"
    private static let host = "(\(ipLiteral)|\(ipv4address)|\(regName))"
    private static let port = "[0-9]*"
    private static let authority = "(\(userinfo)@)?\(host)(:\(port))?"
    private static let dateFullyear = "[0-9]{4}"
    private static let dateMday = "[0-9]{2}"
    private static let dateMonth = "[0-9]{2}"
    private static let fullDate = "\(dateFullyear)-\(dateMonth)-\(dateMday)"
    private static let timeHour = "[0-9]{2}"
    private static let timeMinute = "[0-9]{2}"
    private static let timeSecond = "[0-9]{2}"
    private static let timeSecfrac = "\\.[0-9]+"
    private static let partialTime = "\(timeHour):\(timeMinute):\(timeSecond)(\(timeSecfrac))?"
    private static let timeNumoffset = "[+\\-]\(timeHour):\(timeMinute)"
    private static let timeOffset = "([zZ]|\(timeNumoffset))"
    private static let fullTime = "\(partialTime)\(timeOffset)"
    private static let dateTime = "\(fullDate)[tT]\(fullTime)"
    private static let pchar = "(\(unreserved)|\(pctEncoded)|\(subDelims)|[:@])"
    private static let fragment = "(\(pchar)|[/?])*"
    private static let genDelims = "[:/?#\\[\\]@]"
    private static let segment = "(\(pchar))*"
    private static let pathAbempty = "(/\(segment))*"
    private static let segmentNz = "(\(pchar))+"
    private static let pathAbsolute = "/(\(segmentNz)(/\(segment))*)?"
    private static let pathRootless = "\(segmentNz)(/\(segment))*"
    private static let pathEmpty = "(\(pchar)){0}"
    private static let hierPart = "(//\(authority)\(pathAbempty)|\(pathAbsolute)|\(pathRootless)|\(pathEmpty))"
    private static let query = "(\(pchar)|[/?])*"
    private static let reserved = "(\(genDelims)|\(subDelims))"
    private static let scheme = "[a-zA-Z][a-zA-Z0-9+\\-.]*"
    private static let resource = "- \(uri)"

    // MARK: The final regular expression parts
    private static let domain = authority
    private static let address = "0x[0-9A-Fa-f]{40}"
    private static let statement = "(\(reserved)|\(unreserved)| )+"
    private static let uri = "\(scheme):\(hierPart)(\\?\(query))?(\\#\(fragment))?"
    private static let version = "[0-9]+"
    private static let chainId = "[0-9]+"
    private static let nonce = "[a-zA-Z0-9]{8,}"
    private static let issuedAt = dateTime
    private static let expirationTime = dateTime
    private static let notBefore = dateTime
    private static let requestId = "(\(pchar))*"
    private static let resources = "(\\n\(resource))*"

    private static let eip4361Pattern = "(?<\(EIP4361Field.domain.rawValue)>\(domain)) wants you to sign in with your Ethereum account:\\n(?<\(EIP4361Field.address.rawValue)>\(address))\\n\\n((?<\(EIP4361Field.statement.rawValue)>\(statement))\\n)?\\nURI: (?<\(EIP4361Field.uri.rawValue)>\(uri))\\nVersion: (?<\(EIP4361Field.version.rawValue)>\(version))\\nChain ID: (?<\(EIP4361Field.chainId.rawValue)>\(chainId))\\nNonce: (?<\(EIP4361Field.nonce.rawValue)>\(nonce))\\nIssued At: (?<\(EIP4361Field.issuedAt.rawValue)>\(issuedAt))(\\nExpiration Time: (?<\(EIP4361Field.expirationTime.rawValue)>\(expirationTime)))?(\\nNot Before: (?<\(EIP4361Field.notBefore.rawValue)>\(notBefore)))?(\\nRequest ID: (?<\(EIP4361Field.requestId.rawValue)>\(requestId)))?(\\nResources:(?<\(EIP4361Field.resources.rawValue)>\(resources)))?"

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
                                      "((?<\(EIP4361Field.statement.rawValue)>\(statement))\\n)?",
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
        let eip4361Regex = try! NSRegularExpression(pattern: EIP4361.eip4361OptionalPattern)
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
              !domain.isEmpty,
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
