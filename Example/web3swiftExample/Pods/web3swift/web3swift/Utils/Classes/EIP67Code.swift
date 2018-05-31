//
//  EIP67CodeGenerator.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreImage
import BigInt

extension Web3 {

    public struct EIP67Code {
        public var address: EthereumAddress
        public var gasLimit: BigUInt?
        public var amount: BigUInt?
        public var data: DataType?
        
        public enum DataType {
            case data(Data)
            case function(Function)
        }
        public struct Function {
            public var method: String
            public var parameters: [(ABIv2.Element.ParameterType, AnyObject)]
            
            public func toString() -> String? {
                let encoding = method + "(" + parameters.map({ (el) -> String in
                    if let string = el.1 as? String {
                        return el.0.abiRepresentation + " " + string
                    } else if let number = el.1 as? BigUInt {
                        return el.0.abiRepresentation + " " + String(number, radix: 10)
                    } else if let number = el.1 as? BigInt {
                        return el.0.abiRepresentation + " " + String(number, radix: 10)
                    } else if let data = el.1 as? Data {
                        return el.0.abiRepresentation + " " + data.toHexString().addHexPrefix()
                    }
                    return ""
                }).joined(separator: ", ") + ")"
                return encoding
            }
        }
        
        public init (address : EthereumAddress) {
            self.address = address
        }
        
        public init? (address : String) {
            guard let addr = EthereumAddress(address) else {return nil}
            self.address = addr
        }
        
        public func toString() -> String {
            var urlComponents = URLComponents()
            let mainPart = "ethereum:"+self.address.address.lowercased()
            var queryItems = [URLQueryItem]()
            if let amount = self.amount {
                queryItems.append(URLQueryItem(name: "value", value: String(amount, radix: 10)))
            }
            if let gasLimit = self.gasLimit {
                queryItems.append(URLQueryItem(name: "gas", value: String(gasLimit, radix: 10)))
            }
            if let data = self.data {
                switch data {
                case .data(let d):
                    queryItems.append(URLQueryItem(name: "data", value: d.toHexString().addHexPrefix()))
                case .function(let f):
                    if let enc = f.toString() {
                        queryItems.append(URLQueryItem(name: "function", value: enc))
                    }
                }
            }
            urlComponents.queryItems = queryItems
            if let url = urlComponents.url {
                return mainPart + url.absoluteString
            }
            return mainPart
        }
        
        public func toImage(scale: Double = 1.0) -> CIImage {
            return EIP67CodeGenerator.createImage(from: self, scale: scale)
        }
    }

    public struct EIP67CodeGenerator {
        
        public static func createImage(from: EIP67Code, scale: Double = 1.0) -> CIImage {
            guard let string = from.toString().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return CIImage()}
            guard let data = string.data(using: .utf8, allowLossyConversion: false) else {return CIImage()}
            let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage" : data, "inputCorrectionLevel":"L"])
            guard var image = filter?.outputImage else {return CIImage()}
            let transformation = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            image = image.transformed(by: transformation)
            return image
        }
    }

    public struct EIP67CodeParser {
        public static func parse(_ data: Data) -> EIP67Code? {
            guard let string = String(data: data, encoding: .utf8) else {return nil}
            return parse(string)
        }
        
        public static func parse(_ string: String) -> EIP67Code? {
            guard string.hasPrefix("ethereum:") else {return nil}
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else {return nil}
            guard let encoding = striped[1].removingPercentEncoding else {return nil}
            guard let url = URL.init(string: encoding) else {return nil}
            guard let address = EthereumAddress(url.lastPathComponent) else {return nil}
            var code = EIP67Code(address: address)
            guard let components = URLComponents(string: encoding)?.queryItems else {return code}
            for comp in components {
                switch comp.name {
                case "value":
                    guard let value = comp.value else {return nil}
                    guard let val = BigUInt(value, radix: 10) else {return nil}
                    code.amount = val
                case "gas":
                    guard let value = comp.value else {return nil}
                    guard let val = BigUInt(value, radix: 10) else {return nil}
                    code.gasLimit = val
                case "data":
                    guard let value = comp.value else {return nil}
                    guard let data = Data.fromHex(value) else {return nil}
                    code.data = EIP67Code.DataType.data(data)
                case "function":
                    continue
                default:
                    continue
                }
            }
            return code
        }
    }
}
