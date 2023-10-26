//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import web3secp256k1

public class PlainKeystore: AbstractKeystore {

    public var isHDKeystore: Bool = false

    private var privateKey: Data

    public var addresses: [EthereumAddress]?

    public func UNSAFE_getPrivateKeyData(password: String = "", account: EthereumAddress) throws -> Data {
        return self.privateKey
    }

    public convenience init?(privateKey: String) {
        guard let privateKeyData = Data.fromHex(privateKey) else { return nil }
        self.init(privateKey: privateKeyData)
    }

    public init?(privateKey: Data) {
        guard SECP256K1.verifyPrivateKey(privateKey: privateKey) else { return nil }
        guard let publicKey = Utilities.privateToPublic(privateKey, compressed: false) else { return nil }
        guard let address = Utilities.publicToAddress(publicKey) else { return nil }
        self.addresses = [address]
        self.privateKey = privateKey
    }
}
