//
//  EIP681.swift
//  web3swift
//
//  Created by Alex Vlasov on 08.09.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
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
            public var type: ABIv2.Element.ParameterType
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
        public var function: ABIv2.Element.Function?
        
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

//        public struct Function {
//            public var method: String
//            public var parameters: [(ABIv2.Element.ParameterType, AnyObject)]
//
//            public func toString() -> String? {
//                let encoding = method + "(" + parameters.map({ (el) -> String in
//                    if let string = el.1 as? String {
//                        return el.0.abiRepresentation + " " + string
//                    } else if let number = el.1 as? BigUInt {
//                        return el.0.abiRepresentation + " " + String(number, radix: 10)
//                    } else if let number = el.1 as? BigInt {
//                        return el.0.abiRepresentation + " " + String(number, radix: 10)
//                    } else if let data = el.1 as? Data {
//                        return el.0.abiRepresentation + " " + data.toHexString().addHexPrefix()
//                    }
//                    return ""
//                }).joined(separator: ", ") + ")"
//                return encoding
//            }
//        }
    }
    
    public struct EIP681CodeParser {
//        static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?"
        static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?\\/?(.*)?$"
        
        public static func parse(_ data: Data) -> EIP681Code? {
            guard let string = String(data: data, encoding: .utf8) else {return nil}
            return parse(string)
        }
        
        public static func parse(_ string: String) -> EIP681Code? {
            guard string.hasPrefix("ethereum:") else {return nil}
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else {return nil}
            guard let encoding = striped[1].removingPercentEncoding else {return nil}
//            guard let url = URL.init(string: encoding) else {return nil}
            let matcher = try! NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
            guard match.count == 1 else {return nil}
            guard match[0].numberOfRanges == 5 else {return nil}
            var addressString: String? = nil
            var chainIDString: String? = nil
            var tail: String? = nil
//            if let payModifierRange = Range(match[0].range(at: 1), in: encoding) {
//                let payModifierString = String(encoding[payModifierRange])
//                print(payModifierString)
//            }
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
            var inputs = [ABIv2.Element.InOut]()
            for comp in queryItems {
                if let inputType = try? ABIv2TypeParser.parseTypeString(comp.name) {
                    guard let value = comp.value else {continue}
                    var nativeValue: AnyObject? = nil
                    switch inputType {
                    case .address:
                        let val = EIP681Code.TargetAddress(value)
                        nativeValue = val as AnyObject
                    case .uint(bits: _):
                        if let val = BigUInt(value, radix: 10) {
                            nativeValue = val as AnyObject
                        } else if let val = BigUInt(value.stripHexPrefix(), radix: 16) {
                            nativeValue = val as AnyObject
                        }
                    default:
                        continue
                    }
                    if nativeValue != nil {
                        inputs.append(ABIv2.Element.InOut(name: String(inputNumber), type: inputType))
                        code.parameters.append(EIP681Code.EIP681Parameter(type: inputType, value: nativeValue!))
                        inputNumber = inputNumber + 1
                    }
                } else {
                    switch comp.name {
                    case "value":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.amount = val
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
                let functionEncoding = ABIv2.Element.Function(name: code.functionName!, inputs: inputs, outputs: [ABIv2.Element.InOut](), constant: false, payable: code.amount != nil)
                code.function = functionEncoding
            }

            print(code)
            return code
        }
    }
}
