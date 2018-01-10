//
//  HMAC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.01.2018.
//

import Foundation

enum ExtendedStringEncoding {
    case hex
    case stringEncoding(String.Encoding)
}


public struct HMAC {
    
    public enum HashAlgo {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
        
        func digestLength() -> Int {
            var result: CInt = 0
            switch self {
            case .MD5:
                result = CC_MD5_DIGEST_LENGTH
            case .SHA1:
                result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:
                result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:
                result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:
                result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:
                result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
        
        func digestType() -> Int {
            var result: CInt = 0
            switch self {
            case .MD5:
                result = kCCHmacAlgMD5
            case .SHA1:
                result = kCCHmacAlgSHA1
            case .SHA224:
                result = kCCHmacAlgSHA224
            case .SHA256:
                result = kCCHmacAlgSHA256
            case .SHA384:
                result = kCCHmacAlgSHA384
            case .SHA512:
                result = kCCHmacAlgSHA512
            }
            return Int(result)
        }
    }
    
    public static func hash(inp: String, algo: HashAlgo, encoding: ExtendedStringEncoding = .stringEncoding(String.Encoding.utf8)) -> Data? {
        switch encoding {
        case .hex:
                guard let stringData = Data.fromHex(inp) else {return nil}
                return digest(input: stringData, algo: algo)
        case .stringEncoding(let enc):
                guard let stringData = inp.data(using: enc, allowLossyConversion: false) else {return nil}
                return digest(input: stringData, algo: algo)
        }
    }
    
    public static func hash(input : Data, algo: HashAlgo) -> Data {
        let digestLength = algo.digestLength()
        var hash = [UInt8](repeating: 0, count: digestLength)
        switch algo {
        case .MD5:
            CC_MD5(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA1:
            CC_SHA1(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA224:
            CC_SHA224(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA256:
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA384:
            CC_SHA384(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA512:
            CC_SHA512(input.bytes, UInt32(input.length), &hash)
            break
        }
        return Data(bytes: hash, length: digestLength)
    }
    
    public static func hmac(input : Data, key: Data, algo: HashAlgo) -> Data {
//        CCHmac(CCHmacAlgorithm algorithm, const void *key, size_t keyLength, const void *data,
//            size_t dataLength, void *macOut);
        let digestLength = algo.digestLength()
        var hash = [UInt8](repeating: 0, count: digestLength)
        
        let keyLength = key.count
        let inputLength = input.count
        
        switch algo {
        case .MD5:
            CCHmac(algo.digestType(), key.bytes, UInt32(keyLength), input.bytes, UInt32(inputLength), &hash)
//            CC_MD5(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA1:
            CC_SHA1(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA224:
            CC_SHA224(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA256:
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA384:
            CC_SHA384(input.bytes, UInt32(input.length), &hash)
            break
        case .SHA512:
            CC_SHA512(input.bytes, UInt32(input.length), &hash)
            break
        }
        return Data(bytes: hash, length: digestLength)
    }
}


extension Data {
    public func paddedForHMAC(algo: HMAC.HashAlgo) -> Data? {
        return nil
    }
}


