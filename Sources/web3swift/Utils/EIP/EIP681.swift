//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

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
            public var value: AnyObject
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
    }

    public struct EIP681CodeParser {
        //  static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?"
        static var addressRegex = "^(pay-)?([0-9a-zA-Z.]+)(@[0-9]+)?\\/?(.*)?$"

        public static func parse(_ data: Data) -> EIP681Code? {
            guard let string = String(data: data, encoding: .utf8) else {return nil}
            return parse(string)
        }

        public static func parse(_ string: String) -> EIP681Code? {
            guard string.hasPrefix("ethereum:") else {return nil}
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else {return nil}
            guard let encoding = striped[1].removingPercentEncoding else {return nil}
            //  guard let url = URL.init(string: encoding) else {return nil}
            let matcher = try! NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
            guard match.count == 1 else {return nil}
            guard match[0].numberOfRanges == 5 else {return nil}
            var addressString: String? = nil
            var chainIDString: String? = nil
            var tail: String? = nil
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
            guard let address = addressString else {return nil}
            let targetAddress = EIP681Code.TargetAddress(address)

            var code = EIP681Code(targetAddress)
            if chainIDString != nil {
                chainIDString!.remove(at: chainIDString!.startIndex)
                code.chainID = BigUInt(chainIDString!)
            }
            if tail == nil {
                return code
            }
            guard let components = URLComponents(string: tail!) else {return code}
            if components.path == "" {
                code.isPayRequest = true
            } else {
                code.functionName = components.path
            }
            guard let queryItems = components.queryItems else {return code}
            var inputNumber: Int = 0
            var inputs = [ABI.Element.InOut]()
            for comp in queryItems {
                if let inputType = try? ABITypeParser.parseTypeString(comp.name) {
                    guard let value = comp.value else {continue}
                    var nativeValue: AnyObject? = nil
                    switch inputType {
                    case .address:
                        let val = EIP681Code.TargetAddress(value)
                        switch val {
                        case .ethereumAddress(let ethereumAddress):
                            nativeValue = ethereumAddress as AnyObject
                        //  default:
                        //      return nil
                        case .ensAddress(let ens):
                            do {
                                let web = web3(provider: InfuraProvider(Networks.fromInt(Int(code.chainID ?? 1)) ?? Networks.Mainnet)!)
                                let ensModel = ENS(web3: web)
                                try ensModel?.setENSResolver(withDomain: ens)
                                let address = try ensModel?.getAddress(forNode: ens)
                                nativeValue = address as AnyObject
                            } catch {
                                return nil
                            }
                        }
                    case .uint(bits: _):
                        if let val = BigUInt(value, radix: 10) {
                            nativeValue = val as AnyObject
                        } else if let val = BigUInt(value.stripHexPrefix(), radix: 16) {
                            nativeValue = val as AnyObject
                        }
                    case .int(bits: _):
                        if let val = BigInt(value, radix: 10) {
                            nativeValue = val as AnyObject
                        } else if let val = BigInt(value.stripHexPrefix(), radix: 16) {
                            nativeValue = val as AnyObject
                        }
                    case .string:
                        nativeValue = value as AnyObject
                    case .dynamicBytes:
                        if let val = Data.fromHex(value) {
                            nativeValue = val as AnyObject
                        } else if let val = value.data(using: .utf8) {
                            nativeValue = val as AnyObject
                        }
                    case .bytes(length: _):
                        if let val = Data.fromHex(value) {
                            nativeValue = val as AnyObject
                        } else if let val = value.data(using: .utf8) {
                            nativeValue = val as AnyObject
                        }
                    case .bool:
                        switch value {
                        case "true", "True", "TRUE", "1":
                            nativeValue = true as AnyObject
                        case "false", "False", "FALSE", "0":
                            nativeValue = false as AnyObject
                        default:
                            nativeValue = true as AnyObject
                        }
                    default:
                        continue
                    }
                    if nativeValue != nil {
                        inputs.append(ABI.Element.InOut(name: String(inputNumber), type: inputType))
                        code.parameters.append(EIP681Code.EIP681Parameter(type: inputType, value: nativeValue!))
                        inputNumber = inputNumber + 1
                    } else {
                        return nil
                    }
                } else {
                    switch comp.name {
                    case "value":
                        guard let value = comp.value else {return nil}
                        let splittedValue = value.split(separator: "e")
                        if splittedValue.count <= 1 {
                            guard let val = BigUInt(value, radix: 10) else {return nil }
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
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.gasLimit = val
                    case "gasLimit":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.gasLimit = val
                    case "gasPrice":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
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

            print(code)
            return code
        }
    }
}
