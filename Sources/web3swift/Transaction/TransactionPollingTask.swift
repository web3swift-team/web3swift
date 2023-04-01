//
//  TransactionPollingTask.swift
//
//  Created by JeneaVranceanu on 10.03.2023.
//

import Foundation
import Web3Core

/// Monitors a transaction's state on blockchain until transaction is completed successfully or not.
final public class TransactionPollingTask {

    private enum DelayUnit: UInt64 {
        case shortest = 1
        case medium = 5
        case longest = 60

        func shouldIncreaseDelay(_ startTime: Date) -> Bool {
            let timePassed = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            switch self {
            case .shortest:
                return timePassed > 10
            case .medium:
                return timePassed > 120
            case .longest:
                return false
            }
        }

        var nextDelayUnit: DelayUnit {
            switch self {
            case .shortest:
                return .medium
            case .medium, .longest:
                return .longest
            }
        }
    }

    public let transactionHash: Data

    private let web3Instance: Web3
    private var delayUnit: DelayUnit = .shortest

    public init(transactionHash: Data, web3Instance: Web3) {
        self.transactionHash = transactionHash
        self.web3Instance = web3Instance
    }

    public func wait() async throws -> TransactionReceipt {
        let startTime = Date()
        while true {
            let transactionReceipt = try await web3Instance.eth.transactionReceipt(transactionHash)

            if transactionReceipt.status != .notYetProcessed {
                return transactionReceipt
            }

            if delayUnit.shouldIncreaseDelay(startTime) {
                delayUnit = delayUnit.nextDelayUnit
            }

            try await Task.sleep(nanoseconds: delayUnit.rawValue)
        }
    }
}
