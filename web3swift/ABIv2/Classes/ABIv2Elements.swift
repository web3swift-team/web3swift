//
//  ABIElements.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension ABIv2 {
    // JSON Decoding
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
    }
    
//    public struct InputComponent: Decodable {
//
//    }

    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
    }

    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABIv2.Input]?
        var outputs: [ABIv2.Output]?
        var anonymous: Bool?
    }
    
    public enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public struct InOut {
            let name: String
            let type: ParameterType
        }
        
        public struct Function {
            let name: String?
            let inputs: [InOut]
            let outputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool
            
            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
}


