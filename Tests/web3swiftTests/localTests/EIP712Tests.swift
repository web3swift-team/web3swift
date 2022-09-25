import XCTest
import Core
@testable import web3swift

class EIP712Tests: LocalTestCase {
    func testWithoutChainId() throws {
        let to = EthereumAddress("0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d")!
        let value = EIP712.UInt256(0)
        let amountLinen = EIP712.UInt256("0001000000000000000")//
        let function = ABI.Element.Function(
            name: "approveAndMint",
            inputs: [
                .init(name: "cToken", type: .address),
                .init(name: "mintAmount", type: .uint(bits: 256))],
            outputs: [.init(name: "", type: .bool)],
            constant: false,
            payable: false)
        let object = ABI.Element.function(function)
        let safeTxData = object.encodeParameters([
            EthereumAddress("0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72")! as AnyObject,
            amountLinen as AnyObject
        ])!
        let operation: EIP712.UInt8 = 1
        let safeTxGas = EIP712.UInt256(250000)
        let baseGas = EIP712.UInt256(60000)
        let gasPrice = EIP712.UInt256("20000000000")
        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let refundReceiver = EthereumAddress("0x7c07D32e18D6495eFDC487A32F8D20daFBa53A5e")!
        let nonce: EIP712.UInt256 = .init(6)
        let safeTX = SafeTx(
            to: to,
            value: value,
            data: safeTxData,
            operation: operation,
            safeTxGas: safeTxGas,
            baseGas: baseGas,
            gasPrice: gasPrice,
            gasToken: gasToken,
            refundReceiver: refundReceiver,
            nonce: nonce)
        let password = ""
        let chainId: EIP712.UInt256? = nil
        let verifyingContract = EthereumAddress("0x40c21f00Faafcf10Cc671a75ea0de62305199DC1")!
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")!
        let account = keystore.addresses?[0]
        let signature = try Web3Signer.signEIP712(
            safeTX,
            keystore: keystore,
            verifyingContract: verifyingContract,
            account: account!,
            password: password,
            chainId: chainId)
        XCTAssertEqual(signature.toHexString(), "bf3182a3f52e65b416f86e76851c8e7d5602aef28af694f31359705b039d8d1931d53f3d5088ac7195944e8a9188d161ba3757877d08105885304f65282228c71c")
    }

    func testWithChainId() throws {
        let to = EthereumAddress("0x3F06bAAdA68bB997daB03d91DBD0B73e196c5A4d")!
        let value = EIP712.UInt256(0)
        let amount = EIP712.UInt256("0001000000000000000")
        let function = ABI.Element.Function(
            name: "approveAndMint",
            inputs: [
                .init(name: "cToken", type: .address),
                .init(name: "mintAmount", type: .uint(bits: 256))],
            outputs: [.init(name: "", type: .bool)],
            constant: false,
            payable: false)
        let object = ABI.Element.function(function)
        let safeTxData = object.encodeParameters([
            EthereumAddress("0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72")! as AnyObject,
            amount as AnyObject
        ])!
        let operation: EIP712.UInt8 = 1
        let safeTxGas = EIP712.UInt256(250000)
        let baseGas = EIP712.UInt256(60000)
        let gasPrice = EIP712.UInt256("20000000000")
        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let refundReceiver = EthereumAddress("0x7c07D32e18D6495eFDC487A32F8D20daFBa53A5e")!
        let nonce: EIP712.UInt256 = .init(0)
        let safeTX = SafeTx(
            to: to,
            value: value,
            data: safeTxData,
            operation: operation,
            safeTxGas: safeTxGas,
            baseGas: baseGas,
            gasPrice: gasPrice,
            gasToken: gasToken,
            refundReceiver: refundReceiver,
            nonce: nonce)
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")!
        let verifyingContract = EthereumAddress("0x76106814dc6150b0fe510fbda4d2d877ac221270")!
        let account = keystore.addresses?[0]
        let password  = ""
        let chainId: EIP712.UInt256? = EIP712.UInt256(42)
        let signature = try Web3Signer.signEIP712(
            safeTX,
            keystore: keystore,
            verifyingContract: verifyingContract,
            account: account!,
            password: password,
            chainId: chainId)
        XCTAssertEqual(signature.toHexString(), "f1f423cb23efad5035d4fb95c19cfcd46d4091f2bd924680b88c4f9edfa1fb3a4ce5fc5d169f354e3b464f45a425ed3f6203af06afbacdc5c8224a300ce9e6b21b")
    }
}
