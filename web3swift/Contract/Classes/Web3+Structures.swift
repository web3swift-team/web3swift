//
//  Web3+Structures.swift
//  Alamofire
//
//  Created by Alexander Vlasov on 26.12.2017.
//

import Foundation
import BigInt

public struct TransactionDetails {
    public var hash: String
    public var nonce: BigUInt
    public var blockHash: String?
    public var blockNumber: BigUInt?
    public var transactionIndex: BigUInt?
    public var from: EthereumAddress
    public var to: EthereumAddress
    public var value: BigUInt
    public var gas: BigUInt
    public var gasPrice: BigUInt
    public var input: Data
    
    public init? (_ json: [String: Any]) {
        guard let h = json["hash"] as? String else {return nil}
        guard let n = json["nonce"] as? String else {return nil}
        let bh = json["blockHash"] as? String
        let bn = json["blockNumber"] as? String
        let ti = json["transactionIndex"] as? String
        guard let f = json["from"] as? String else {return nil}
        guard let t = json["to"] as? String else {return nil}
        guard let v = json["value"] as? String else {return nil}
        guard let g = json["gas"] as? String else {return nil}
        guard let gp = json["gasPrice"] as? String else {return nil}
        guard let i = json["input"] as? String else {return nil}
        
        hash = h
        guard let nUnwrapped = BigUInt(n.stripHexPrefix(), radix: 16) else {return nil}
        nonce = nUnwrapped
        blockHash = bh
        if bn != nil {
            blockNumber = BigUInt(bn!.stripHexPrefix(), radix: 16)
        }
        if ti != nil {
            transactionIndex = BigUInt(ti!.stripHexPrefix(), radix: 16)
        }
        
        from = EthereumAddress(f)
        to = EthereumAddress(t)
        guard let vUnwrapped = BigUInt(v.stripHexPrefix(), radix: 16) else {return nil}
        guard let gUnwrapped = BigUInt(g.stripHexPrefix(), radix: 16) else {return nil}
        guard let gpUnwrapped = BigUInt(gp.stripHexPrefix(), radix: 16) else {return nil}
        value = vUnwrapped
        gas = gUnwrapped
        gasPrice = gpUnwrapped
        input = Data(Array<UInt8>(hex: i.lowercased().stripHexPrefix()))
    }
}

public struct TransactionReceipt {
    public var transactionHash: String
    public var blockHash: String
    public var blockNumber: BigUInt
    public var transactionIndex: BigUInt
    public var contractAddress: EthereumAddress?
    public var cumulativeGasUsed: BigUInt
    public var gasUsed: BigUInt
    public var logs: [EventLog]
    public var status: TXStatus
    
    public enum TXStatus {
        case ok
        case failed
    }
    
    public init? (_ json: [String: Any]) {
        guard let h = json["transactionHash"] as? String else {return nil}
        guard let bh = json["blockHash"] as? String else {return nil}
        guard let bn = json["blockNumber"] as? String else {return nil}
        guard let ti = json["transactionIndex"] as? String else {return nil}
        let ca = json["contractAddress"] as? String
        guard let cgu = json["cumulativeGasUsed"] as? String else {return nil}
        guard let gu = json["gasUsed"] as? String else {return nil}
        guard let ls = json["logs"] as? Array<[String:Any]> else {return nil}
        guard let st = json["status"] as? String else {return nil}
        
        transactionHash = h
        blockHash = bh
        guard let bnUnwrapped = BigUInt(bn.stripHexPrefix(), radix: 16) else {return nil}
        blockNumber = bnUnwrapped
        guard let tiUnwrapped = BigUInt(ti.stripHexPrefix(), radix: 16) else {return nil}
        transactionIndex = tiUnwrapped
        if ca != nil {
            contractAddress = EthereumAddress(ca!.addHexPrefix())
        }
        guard let cguUnwrapped = BigUInt(cgu.stripHexPrefix(), radix: 16) else {return nil}
        cumulativeGasUsed = cguUnwrapped
        guard let guUnwrapped = BigUInt(gu.stripHexPrefix(), radix: 16) else {return nil}
        gasUsed = guUnwrapped
        var allLogs = [EventLog]()
        for l in ls {
            guard let log = EventLog(l) else {return nil}
            allLogs.append(log)
        }
        logs = allLogs
        if st == "0x1" {
            status = TXStatus.ok
        } else {
            status = TXStatus.failed
        }
    }
}

public struct EventLog {
    public var address: EthereumAddress
    public var data: Data
    public var logIndex: BigUInt
    public var removed: Bool
    public var topics: [Data]
    
    public init? (_ json: [String: Any]) {
        guard let ad = json["address"] as? String else {return nil}
        guard let d = json["data"] as? String else {return nil}
        guard let li = json["logIndex"] as? String else {return nil}
        guard let rm = json["removed"] as? Int else {return nil}
        guard let tpc = json["topics"] as? [String] else {return nil}
        address = EthereumAddress(ad)
        data = Data(Array<UInt8>(hex: d.lowercased().stripHexPrefix()))
        
        guard let liUnwrapped = BigUInt(li.stripHexPrefix(), radix: 16) else {return nil}
        logIndex = liUnwrapped
        removed = rm == 1 ? true : false
        var tops = [Data]()
        for t in tpc {
            let topic = Data(Array<UInt8>(hex: t.lowercased().stripHexPrefix()))
            tops.append(topic)
        }
        topics = tops
    }
}

