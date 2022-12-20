//
//  SyncingInfo.swift
//
//  Created by JeneaVranceanu on 16.12.2022.
//

import Foundation

/// Returned to a WebSocket connections that subscribed on `"syncing"` event.
public struct SyncingInfo: Decodable {
    public struct Status: Decodable {
        public let startingBlock: Int
        public let currentBlock: Int
        public let highestBlock: Int
        public let pulledStates: Int
        public let knownStates: Int
    }

    public let syncing: Bool
    public let status: Status?
}
