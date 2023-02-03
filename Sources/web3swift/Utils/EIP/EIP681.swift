//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3 {

    //    request                 = "ethereum" ":" [ "pay-" ]target_address [ "@" chain_id ] [ "/" function_name ] [ "?" parameters ]
    //    target_address          = ethereum_address
    //    chain_id                = 1*DIGIT
    //    function_name           = STRING
    //    ethereum_address        = ( "0x" 40*40HEXDIG ) / ENS_NAME
    //    parameters              = parameter *( "&" parameter )
    //    parameter               = key "=" value
    //    key                     = "value" / "gas" / "gasLimit" / "gasPrice" / TYPE
    //    value                   = number / ethereum_address / STRING
    //    number                  = [ "-" / "+" ] *DIGIT [ "." 1*DIGIT ] [ ( "e" / "E" ) [ 1*DIGIT ] [ "+" UNIT ]

    public struct EIP681Code {
        public struct EIP681Parameter {
            public var type: ABI.Element.ParameterType
            public var value: Any

            public init(type: ABI.Element.ParameterType, value: Any) {
                self.type = type
                self.value = value
            }
        }
        public var isPayRequest: Bool
        public var targetAddress: TargetAddress
        public var chainID: BigUInt?
        public var functionName: String?
        public var parameters: [EIP681Parameter] = [EIP681Parameter]()
        public var gasLimit: BigUInt?
        public var gasPrice: BigUInt?
        public var amount: BigUInt?
        public var function: ABI.Element.Function?

        public enum TargetAddress {
            case ethereumAddress(EthereumAddress)
            case ensAddress(String)
            public init(_ string: String) {
                if let ethereumAddress = EthereumAddress(string) {
                    self = TargetAddress.ethereumAddress(ethereumAddress)
                } else {
                    self = TargetAddress.ensAddress(string)
                }
            }
        }

        public init(_ targetAddress: TargetAddress, isPayRequest: Bool = false) {
            self.isPayRequest = isPayRequest
            self.targetAddress = targetAddress
        }

        public func makeEIP681Link(urlEncode: Bool = false) -> String? {
            let address: String
            switch targetAddress {
            case .ethereumAddress(let ethereumAddress):
                address = ethereumAddress.address
            case let .ensAddress(ensAdress):
                address = ensAdress
            }
            var link = "ethereum:\(address)\(chainID != nil ? "@\(chainID!.description)" : "")"
            if let functionName = functionName, !functionName.isEmpty {
                link = "\(link)/\(functionName)"
            }
            if !parameters.isEmpty {
                let queryParameters: [String] = parameters.compactMap { eip681Parameter in
                    guard let queryValue = Web3
                        .EIP681CodeEncoder
                        .encodeFunctionArgument(eip681Parameter.type, eip681Parameter.value)
                    else {
                        return nil
                    }
                    return "\(eip681Parameter.type.abiRepresentation)=\(queryValue)"
                }

                if queryParameters.count == parameters.count {
                    link = "\(link)?\(queryParameters.joined(separator: "&"))"
                }
            }
            return urlEncode ? link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) : link
        }
    }

    public struct EIP681CodeEncoder {
        public static func encodeFunctionArgument(_ inputType: ABI.Element.ParameterType,
                                                  _ rawValue: Any) -> String? {
            switch inputType {
            case .address:
                if let ethAddress = rawValue as? EthereumAddress {
                    return ethAddress.address
                }
                if let bytes = rawValue as? Data,
                   let ethAddress = EthereumAddress(bytes) {
                    return ethAddress.address
                }
                if let string = rawValue as? String {
                    if let ethAddress = EthereumAddress(string) {
                        return ethAddress.address
                    }
                    if URL(string: string) != nil {
                        return string
                    }
                }
                return nil
            case .uint(bits: _):
                let value: BigUInt?
                if let bigInt = rawValue as? BigInt {
                    value = BigUInt(bigInt)
                } else if let bigUInt = rawValue as? BigUInt {
                    value = bigUInt
                } else if let bytes = rawValue as? Data {
                    value = BigUInt(bytes)
                } else if let string = rawValue as? String {
                    value = BigUInt(string, radix: 10) ?? BigUInt(string.stripHexPrefix(), radix: 16)
                } else if let number = rawValue as? Int {
                    value = BigUInt(exactly: number)
                } else if let number = rawValue as? Double {
                    value = BigUInt(exactly: number)
                } else {
                    value = nil
                }
                return value?.description
            case .int(bits: _):
                let value: BigInt?
                if let bigInt = rawValue as? BigInt {
                    value = bigInt
                } else if let bigUInt = rawValue as? BigUInt {
                    value = BigInt(bigUInt)
                } else if let bytes = rawValue as? Data {
                    value = BigInt(bytes)
                } else if let string = rawValue as? String {
                    value = BigInt(string, radix: 10) ?? BigInt(string.stripHexPrefix(), radix: 16)
                } else if let number = rawValue as? Int {
                    value = BigInt(exactly: number)
                } else if let number = rawValue as? Double {
                    value = BigInt(exactly: number)
                } else {
                    value = nil
                }
                return value?.description
            case .string:
                if let bytes = rawValue as? Data,
                   let string = String(data: bytes, encoding: .utf8) {
                    return string
                } else if let string = rawValue as? String {
                    return string
                }
                return nil
            case .dynamicBytes:
                if let bytes = rawValue as? Data {
                    return bytes.toHexString().addHexPrefix()
                } else if let bytes = rawValue as? [UInt8] {
                    return Data(bytes).toHexString().addHexPrefix()
                } else if let string = rawValue as? String {
                    if let bytes = Data.fromHex(string) {
                        return bytes.toHexString().addHexPrefix()
                    }
                    return string.data(using: .utf8)?.toHexString().addHexPrefix()
                }
                return nil
            case let .bytes(length):
                var data: Data?
                if let bytes = rawValue as? Data {
                    data = bytes
                } else if let bytes = rawValue as? [UInt8] {
                    data = Data(bytes)
                } else if let string = rawValue as? String {
                    if let bytes = Data.fromHex(string) {
                        data = bytes
                    } else {
                        data = string.data(using: .utf8)
                    }
                }

                if let data = data,
                   data.count == length {
                    return data.toHexString().addHexPrefix()
                }
                return nil
            case .bool:
                if let bool = rawValue as? Bool {
                    return bool ? "true" : "false"
                }
                if let number = rawValue as? Int,
                   let int = BigInt(exactly: number) {
                    return int == 0 ? "false" : "true"
                }
                if let number = rawValue as? Double,
                   let int = BigInt(exactly: number) {
                    return int == 0 ? "false" : "true"
                }
                if let string = rawValue as? String {
                    switch string.lowercased() {
                    case "true", "yes", "1":
                        return "true"
                    default:
                        return "false"
                    }
                }
                if let bytes = rawValue as? Data {
                    return bytes.count == 0 || bytes.count == 1 && bytes.first == 0 ? "false" : "true"
                }
                return nil
            case let .array(type, length):
                if let array = rawValue as? [Any] {
                    let mappedArray = array.compactMap { object in
                        encodeFunctionArgument(type, object)
                    }

                    if length != 0 && UInt64(mappedArray.count) == length {
                        return "[\(mappedArray.joined(separator: ","))]"
                    } else if length == 0 && mappedArray.count == array.count {
                        return "[\(mappedArray.joined(separator: ","))]"
                    }
                }
                return nil
            case .tuple:
                // TODO: implement!
                return nil
            default: return nil
            }
        }
    }

    public struct EIP681CodeParser {
        //  static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?"
        static var addressRegex = "^(pay-)?([0-9a-zA-Z.]+)(@[0-9]+)?\\/?(.*)?$"

        public static func parse(_ data: Data) async -> EIP681Code? {
            guard let string = String(data: data, encoding: .utf8) else { return nil }
            return await parse(string)
        }

        // TODO: throws errors instead of returning `nil`
        /// Attempts to parse given string as EIP681 code.
        /// Note: that ENS addresses as parameters will be attempted to be resolved into Ethereum addresses.
        /// Thus, make sure that given raw EIP681 code has chain ID set or default Ethereum Mainnet chan ID will be used instead.
        /// - Parameter string: raw, encoded EIP681 code.
        /// - Returns: parsed EIP681 code or `nil` is something has failed.
        public static func parse(_ string: String) async -> EIP681Code? {
            guard string.hasPrefix("ethereum:") else { return nil }
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else { return nil }
            guard let encoding = striped[1].removingPercentEncoding else { return nil }
            //  guard let url = URL.init(string: encoding) else { return nil }
            let matcher = try! NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
            guard match.count == 1 else { return nil }
            guard match[0].numberOfRanges == 5 else { return nil }
            var addressString: String?
            var chainIDString: String?
            var tail: String?
            //  if let payModifierRange = Range(match[0].range(at: 1), in: encoding) {
            //      let payModifierString = String(encoding[payModifierRange])
            //      print(payModifierString)
            //  }
            if  let addressRange = Range(match[0].range(at: 2), in: encoding) {
                addressString = String(encoding[addressRange])
            }
            if  let chainIDRange = Range(match[0].range(at: 3), in: encoding) {
                chainIDString = String(encoding[chainIDRange])
            }
            if  let tailRange = Range(match[0].range(at: 4), in: encoding) {
                tail = String(encoding[tailRange])
            }
            guard let address = addressString else { return nil }
            let targetAddress = EIP681Code.TargetAddress(address)

            var code = EIP681Code(targetAddress)
            if chainIDString != nil {
                chainIDString!.remove(at: chainIDString!.startIndex)
                code.chainID = BigUInt(chainIDString!)
            }
            if tail == nil {
                return code
            }
            guard let components = URLComponents(string: tail!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? tail!) else {return code}
            if components.path == "" {
                code.isPayRequest = true
            } else {
                code.functionName = components.path
            }
            guard let queryItems = components.queryItems else { return code }
            var inputNumber: Int = 0
            var inputs = [ABI.Element.InOut]()
            for comp in queryItems {
                if let inputType = try? ABITypeParser.parseTypeString(comp.name) {
                    guard let rawValue = comp.value,
                          let functionArgument = await parseFunctionArgument(inputType,
                                                                             rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                                             chainID: code.chainID,
                                                                             inputNumber: inputNumber)
                    else { continue }

                    inputs.append(functionArgument.argType)
                    code.parameters.append(functionArgument.parameter)
                    inputNumber = inputNumber + 1
                } else {
                    switch comp.name {
                    case "value":
                        guard let value = comp.value else { return nil }
                        let splittedValue = value.split(separator: "e")
                        if splittedValue.count <= 1 {
                            guard let val = BigUInt(value, radix: 10) else { return nil }
                            code.amount = val
                        } else if splittedValue.count == 2 {
                            guard let power = Double(splittedValue[1]) else { return nil }
                            let splittedNumber = String(splittedValue[0]).replacingOccurrences(of: ",", with: ".").split(separator: ".")
                            var a = BigUInt(pow(10, power))
                            if splittedNumber.count == 1 {
                                guard let number = BigUInt(splittedNumber[0], radix: 10) else { return nil }
                                code.amount = number * a
                            } else if splittedNumber.count == 2 {
                                let stringNumber = String(splittedNumber[0]) + String(splittedNumber[1])
                                let am = BigUInt(pow(10, Double(splittedNumber[1].count)))
                                a = a / am
                                guard let number = BigUInt(stringNumber, radix: 10) else { return nil }
                                code.amount = number * a
                            } else { return nil }
                        } else { return nil }

                    case "gas":
                        guard let value = comp.value else { return nil }
                        guard let val = BigUInt(value, radix: 10) else { return nil }
                        code.gasLimit = val
                    case "gasLimit":
                        guard let value = comp.value else { return nil }
                        guard let val = BigUInt(value, radix: 10) else { return nil }
                        code.gasLimit = val
                    case "gasPrice":
                        guard let value = comp.value else { return nil }
                        guard let val = BigUInt(value, radix: 10) else { return nil }
                        code.gasPrice = val
                    default:
                        continue
                    }
                }
            }

            if code.functionName != nil {
                let functionEncoding = ABI.Element.Function(name: code.functionName!, inputs: inputs, outputs: [ABI.Element.InOut](), constant: false, payable: code.amount != nil)
                code.function = functionEncoding
            }

            return code
        }

        private static func parseFunctionArgument(_ inputType: ABI.Element.ParameterType,
                                                  _ rawValue: String,
                                                  chainID: BigUInt?,
                                                  inputNumber: Int) async -> FunctionArgument? {
            var nativeValue: Any?
            switch inputType {
            case .address:
                let val = EIP681Code.TargetAddress(rawValue)
                switch val {
                case .ethereumAddress(let ethereumAddress):
                    nativeValue = ethereumAddress
                case .ensAddress(let ens):
                    guard let chainID = chainID else { return nil }
                    do {
                        let web = await Web3(provider: InfuraProvider(.fromInt(UInt(chainID)))!)
                        let ensModel = ENS(web3: web)
                        try await ensModel?.setENSResolver(withDomain: ens)
                        let address = try await ensModel?.getAddress(forNode: ens)
                        nativeValue = address
                    } catch {
                        NSLog("Failed to resolve ENS address (parameter nr \(inputNumber)). Error: \(error.localizedDescription)")
                        return nil
                    }
                }
            case .uint(bits: _):
                if let val = BigUInt(rawValue, radix: 10) {
                    nativeValue = val
                } else if let val = BigUInt(rawValue.stripHexPrefix(), radix: 16) {
                    nativeValue = val
                }
            case .int(bits: _):
                if let val = BigInt(rawValue, radix: 10) {
                    nativeValue = val
                } else if let val = BigInt(rawValue.stripHexPrefix(), radix: 16) {
                    nativeValue = val
                }
            case .string:
                nativeValue = rawValue
            case .dynamicBytes:
                if let val = Data.fromHex(rawValue) {
                    nativeValue = val
                } else if let val = rawValue.data(using: .utf8) {
                    nativeValue = val
                }
            case .bytes(length: _):
                if let val = Data.fromHex(rawValue) {
                    nativeValue = val
                } else if let val = rawValue.data(using: .utf8) {
                    nativeValue = val
                }
            case .bool:
                switch rawValue {
                case "true", "True", "TRUE", "1":
                    nativeValue = true
                case "false", "False", "FALSE", "0":
                    nativeValue = false
                default:
                    nativeValue = true
                }
            case let .array(type, length):
                var rawValues: [String] = []
                if case .array = type {
                    guard let internalArrays = splitArrayOfArrays(rawValue),
                          (length == 0 || UInt64(internalArrays.count) == length) else { return nil }
                    rawValues = internalArrays
                } else if case .tuple = type {
                    // TODO: implement!
                } else if case .string = type {
                    guard let strings = splitArrayOfStrings(rawValue),
                          (length == 0 || UInt64(strings.count) == length) else { return nil }
                    rawValues = strings
                } else {
                    let rawValue = String(rawValue.dropFirst().dropLast())
                    rawValues = rawValue.split(separator: ",").map { String($0) }
                }

                var nativeValueArray: [Any] = []

                for value in rawValues {
                    let intermidiateValue = await parseFunctionArgument(type,
                                                                        value,
                                                                        chainID: chainID,
                                                                        inputNumber: inputNumber)?
                        .parameter
                        .value
                    if let intermidiateValue = intermidiateValue {
                        nativeValueArray.append(intermidiateValue)
                    }
                }
                nativeValue = nativeValueArray

                guard nativeValueArray.count == rawValues.count &&
                        (length == 0 || UInt64(rawValues.count) == length) else { return nil }
            case .tuple:
                // TODO: implement!
                return nil
            default: return nil
            }

            guard let nativeValue = nativeValue else { return nil }
            return FunctionArgument(ABI.Element.InOut(name: String(inputNumber), type: inputType),
                                    EIP681Code.EIP681Parameter(type: inputType, value: nativeValue))
        }

        // MARK: - Parsing functions for complex data structures

        /// Attempts to split given ``rawValue`` into `[String]` where each element of that array
        /// represent a valid, stringified, array in of itself.
        /// With an input like `"[[],[],[]]"` the output is expected to be `["[]","[]","[]"]`.
        /// - Parameter rawValue: supposedly an array of arrays in a form `[[...],[...],...]`
        /// - Returns: separated stringified arrays, or `nil` if separation failed.
        private static func splitArrayOfArrays(_ rawValue: String) -> [String]? {
            /// Dropping first and last square brackets.
            /// That modifies the upper bound value of the first match of `squareBracketRegex`.
            let rawValue = String(rawValue.dropFirst().dropLast())

            // TODO: try replacing this manual parsing with JSONDecoder and RawRepresentable

            let squareBracketRegex = try! NSRegularExpression(pattern: "(\\[*)")
            let match = squareBracketRegex.firstMatch(in: rawValue, range: rawValue.fullNSRange)

            guard let bracketsCount = match?.range.upperBound,
                  bracketsCount > 0 else {
                return nil
            }

            let splitRegex = try! NSRegularExpression(pattern: "(\\]){\(bracketsCount)},(\\[){\(bracketsCount)}")
            var indices: [Int] = splitRegex.matches(in: rawValue, range: rawValue.fullNSRange)
                .map { $0.range.lowerBound + bracketsCount }
            if !indices.isEmpty {
                indices.append(rawValue.count)
                var prevIndex = 0
                var result = [String]()
                for index in indices {
                    result.append(rawValue[prevIndex..<index])
                    prevIndex = index + 1
                }
                return result
            }
            return [rawValue]
        }

        /// Attempts to split a string that represents an array of strings.
        /// Example:
        ///
        ///      // input
        ///      "[\"1\",\"abcd,efgh\",\"-=-=-\"]"
        ///      // output
        ///      ["1","abcd,efgh","-=-=-"]
        ///
        ///      // input
        ///      "[1,abcd,efgh,-=-=-]"
        ///      // output
        ///      ["1","abcd","efgh","-=-=-"]
        ///
        /// - Parameter rawValue: stringified array of strings.
        /// - Returns: an array of separated individual elements, or `nil` if separation failed.
        private static func splitArrayOfStrings(_ rawValue: String) -> [String]? {
            /// Dropping first and last square brackets to exclude them from the first and the last separated element.
            let rawValue = String(rawValue.dropFirst().dropLast())

            // TODO: try replacing this manual parsing with JSONDecoder and RawRepresentable

            let elementsBoundary = try! NSRegularExpression(pattern: "\",\"")
            var indices = Array(elementsBoundary
                .matches(in: rawValue, range: rawValue.fullNSRange)
                .map { result in
                    result.range.lowerBound + 1
                })

            if !indices.isEmpty {
                indices.append(rawValue.count)
                var prevIndex = 0
                var rawValues = [String]()
                for index in indices {

                    var argument = rawValue[prevIndex..<index]
                    if let index = argument.firstIndex(of: "\""),
                       argument.distance(from: argument.startIndex, to: index) == 0 {
                        argument = String(argument.dropFirst())
                    }
                    if let index = argument.lastIndex(of: "\""),
                       argument.distance(from: argument.endIndex, to: index) == -1 {
                        argument = String(argument.dropLast())
                    }
                    rawValues.append(argument)
                    prevIndex = index + 1
                }
                return rawValues
            }
            return rawValue.split(separator: ",").map { String($0) }
        }
    }
}

private class FunctionArgument {
    let argType: ABI.Element.InOut
    let parameter: Web3.EIP681Code.EIP681Parameter

    init(_ argType: ABI.Element.InOut,
         _ parameter: Web3.EIP681Code.EIP681Parameter) {
        self.argType = argType
        self.parameter = parameter
    }
}
