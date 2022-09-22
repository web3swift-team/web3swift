import Foundation
import BigInt

/// Represent a log, a record of some action, emitted during transaction execution.
///
/// Example of values it can contain:
///    - `address = 0x53066cddbc0099eb6c96785d9b3df2aaeede5da3;`
///    - `blockHash = 0x779c1f08f2b5252873f08fd6ec62d75bb54f956633bbb59d33bd7c49f1a3d389;`
///    - `blockNumber = 0x4f58f8;`
///    - `data = 0x0000000000000000000000000000000000000000000000004563918244f40000;`
///    - `logIndex = 0x84;`
///    - `removed = 0;`
///    - `topics = [`
///         - `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,`
///         - `0x000000000000000000000000efdcf2c36f3756ce7247628afdb632fa4ee12ec5,`
///         - `0x000000000000000000000000d5395c132c791a7f46fa8fc27f0ab6bacd824484]`
///    - `transactionHash = 0x9f7bb2633abb3192d35f65e50a96f9f7ca878fa2ee7bf5d3fca489c0c60dc79a;`
///    - `transactionIndex = 0x99;`
public struct EventLog: Decodable {
    public var address: EthereumAddress
    public var blockHash: Data
    public var blockNumber: BigUInt
    public var data: Data
    public var logIndex: BigUInt
    public var removed: Bool
    public var topics: [Data]
    public var transactionHash: Data
    public var transactionIndex: BigUInt

    enum CodingKeys: String, CodingKey {
        case address
        case blockHash
        case blockNumber
        case data
        case logIndex
        case removed
        case topics
        case transactionHash
        case transactionIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let address = try container.decode(EthereumAddress.self, forKey: .address)
        self.address = address

        self.blockNumber = try container.decodeHex(BigUInt.self, forKey: .blockNumber)

        self.blockHash = try container.decodeHex(Data.self, forKey: .blockHash)

        self.transactionIndex = try container.decodeHex(BigUInt.self, forKey: .transactionIndex)

        self.transactionHash = try container.decodeHex(Data.self, forKey: .transactionHash)

        self.data = try container.decodeHex(Data.self, forKey: .data)

        self.logIndex = try container.decodeHex(BigUInt.self, forKey: .logIndex)

        let removed = try? container.decodeHex(BigUInt.self, forKey: .removed)
        self.removed = removed == 1 ? true : false

        let topicsStrings = try container.decode([String].self, forKey: .topics)

        self.topics = try topicsStrings.map {
            guard let topic = Data.fromHex($0) else { throw Web3Error.dataError }
            return topic
        }
    }
}

extension EventLog: APIResultType { }
