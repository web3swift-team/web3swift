import XCTest
import Web3Core
@testable import web3swift

class EIP712Tests: XCTestCase {

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
            EthereumAddress("0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72")!,
            amountLinen
        ])!
        let operation: EIP712.UInt8 = 1
        let safeTxGas = EIP712.UInt256(250000)
        let baseGas = EIP712.UInt256(60000)
        let gasPrice = EIP712.UInt256("20000000000")
        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let refundReceiver = EthereumAddress("0x7c07D32e18D6495eFDC487A32F8D20daFBa53A5e")!
        let nonce: EIP712.UInt256 = .init(6)
        let safeTX = GnosisSafeTx(
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
        XCTAssertEqual(signature.toHexString(), "c0567b120d3de6b3042ae3de1aa346e167454c675e1eaf40ea2f9de89e6a95c2783c1aa6c96aa1e0aaead4ae8901052fa9fd7abe4acb331adafd61610e93c3f01c")
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
            EthereumAddress("0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72")!,
            amount
        ])!
        let operation: EIP712.UInt8 = 1
        let safeTxGas = EIP712.UInt256(250000)
        let baseGas = EIP712.UInt256(60000)
        let gasPrice = EIP712.UInt256("20000000000")
        let gasToken = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let refundReceiver = EthereumAddress("0x7c07D32e18D6495eFDC487A32F8D20daFBa53A5e")!
        let nonce: EIP712.UInt256 = .init(0)
        let safeTX = GnosisSafeTx(
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
        XCTAssertEqual(signature.toHexString(), "9ee2aadf14739e1cafc3bc1a0b48457c12419d5b480a8ffa86eb7df538c82d0753ca2a6f8024dea576b383cbcbe5e2b181b087e489298674bf6512756cabc5b01b")
    }

    func testEIP712TypedDataSigning() throws {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")!
        let account = keystore.addresses?[0]
        let eip712TypedData = try EIP712Parser.parse(EIP712TestData.testTypedDataPayload)
        let signature = try Web3Signer.signEIP712(
            eip712TypedData,
            keystore: keystore,
            account: account!)
        XCTAssertEqual(signature.toHexString(), "70d1f5d9eac7b6303683d0792ea8dc93369e3b79888c4e0b86121bec19f479ba4067cf7ac3f8208cbc60a706c4793c2c17e19637298bb31642e531619272b26e1b")
    }
}
