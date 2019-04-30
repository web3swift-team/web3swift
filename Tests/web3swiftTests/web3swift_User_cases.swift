//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
//import EthereumAddress

@testable import web3swift

class web3swift_User_cases: XCTestCase {
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
    func testUserCase1() throws {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"mintingFinished\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"cancelApprove\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"isPrivilegeAddress\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"isBiometricLockedOnlyOwner\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"isAllowedHICAddress\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"addPrivilegeAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"addAllowedHICAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"removePresaleHolder\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_BOPS\",\"type\":\"address\"}],\"name\":\"setBOPSAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"unpause\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_amount\",\"type\":\"uint256\"}],\"name\":\"mint\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"isUtilityHolder\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"paused\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_subtractedValue\",\"type\":\"uint256\"}],\"name\":\"decreaseApproval\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"addPresaleHolder\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"bioLock\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"finishMinting\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"pause\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"removeAllowedHICAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"cancelTransfer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"isPresaleHolder\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"releaseTransfer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"addUtilityHolder\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"isSenderBiometricLocked\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"removePrivilegeAddress\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_addedValue\",\"type\":\"uint256\"}],\"name\":\"increaseApproval\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_beneficiary\",\"type\":\"address\"}],\"name\":\"removeUtilityHolder\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"isBiometricCompleted\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"transferOwnership\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"releaseApprove\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"sha\",\"type\":\"bytes32\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"bioUnlock\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[],\"name\":\"Pause\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[],\"name\":\"Unpause\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"amount\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"BiometricTransferRequest\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"BiometricApprovalRequest\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"beneficiary\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"sha\",\"type\":\"bytes32\"}],\"name\":\"BiometricLocked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"beneficiary\",\"type\":\"address\"}],\"name\":\"BiometricUnlocked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Mint\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[],\"name\":\"MintFinished\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"previousOwner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"newOwner\",\"type\":\"address\"}],\"name\":\"OwnershipTransferred\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"}]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contractAddress = EthereumAddress("0x0f90969738c7a3088907c052cb96bd4d184a9fcf")
        let contract = web3.contract(jsonString, at: contractAddress)
        XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
        let account = EthereumAddress("0xb870065718919ac4f9572ffc4bde0b2516f4e723")!
        let readTransaction = contract!.read("balanceOf", parameters:[account] as [AnyObject])!
        readTransaction.transactionOptions.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
        let response = try readTransaction.callPromise().wait()
        let balance = response["0"] as? BigUInt
        print(balance!.description)
    }
    
    func testUserCase2() {
        let url = URL(string: "https://mainnet.infura.io")!
        let web3 = try? Web3.new(url)
        XCTAssert(web3 != nil, "Failed to create web3 for custom provider")
    }
    
    func testProperGasLimit() throws {
        guard let keystoreData = getKeystoreData() else {return XCTFail()}
        guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let keystoreManager = KeystoreManager.init([keystoreV3])
        web3Rinkeby.addKeystoreManager(keystoreManager)
        let gasPriceRinkeby = try web3Rinkeby.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
        writeTX.transactionOptions.from = keystoreV3.addresses?.first
        writeTX.transactionOptions.gasPrice = .manual(gasPriceRinkeby)
        let gasEstimate = try writeTX.estimateGasPromise().wait()
        writeTX.transactionOptions.gasLimit = .manual(gasEstimate + 1234)
        let assembled = try writeTX.assemblePromise().wait()
        XCTAssert(assembled.gasLimit == gasEstimate + 1234)
    }
    
    func testProperGasPrice() throws {
        guard let keystoreData = getKeystoreData() else {return XCTFail()}
        guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let keystoreManager = KeystoreManager.init([keystoreV3])
        web3Rinkeby.addKeystoreManager(keystoreManager)
        let gasPriceRinkeby = try web3Rinkeby.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
        writeTX.transactionOptions.from = keystoreV3.addresses?.first
        writeTX.transactionOptions.gasPrice = .manual(gasPriceRinkeby * 2)
        let gasEstimate = try writeTX.estimateGasPromise().wait()
        writeTX.transactionOptions.gasLimit = .manual(gasEstimate + 1234)
        let assembled = try writeTX.assemblePromise().wait()
        XCTAssert(assembled.gasLimit == gasEstimate + 1234)
        XCTAssert(assembled.gasPrice == gasPriceRinkeby * 2)
    }
    
    func testParseTransactionDetailsForContractCreation() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let details = try web3.eth.getTransactionDetails("0x1c85b9b7f7c2cbdb3fa264f6b78b226360aa2084c48cf7869b756e0762bd851b")
        print(details)
        XCTAssert(details.transaction.to == .contractDeploymentAddress())
        let receipt = try web3.eth.getTransactionReceipt("0x1c85b9b7f7c2cbdb3fa264f6b78b226360aa2084c48cf7869b756e0762bd851b")
        print(receipt)
        XCTAssert(receipt.contractAddress != nil)
    }
    
    func testNonBatchedRequest() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        web3.requestDispatcher.policy = .NoBatching
        let balanceResult = try web3.eth.getBalance(address: address)
        print(balanceResult)
    }
    
//    func testSendingEthAndTokens() {
//        let web3 = Web3.InfuraMainnetWeb3()
//        let text = "".trimmingCharacters(in: .whitespacesAndNewlines)
//        let data = Data.fromHex(text)!
//        let wallet = try! EthereumKeystoreV3(privateKey: data, password: "")!
//        let keyData = try! JSONEncoder().encode(wallet.keystoreParams)
//        let keystore = EthereumKeystoreV3(keyData)!
//        let manager = KeystoreManager([keystore])
//        web3.addKeystoreManager(manager)
//        let ethToAddress = EthereumAddress("")!
//        let contract1 = web3.contract(Web3.Utils.coldWalletABI, at: ethToAddress, abiVersion: 2)!
//
//        let amount = Web3.Utils.parseToBigUInt("0.01", units: .eth)
//        var options = TransactionOptions.defaultOptions
//        let address = EthereumAddress("")!
//        options.from = address
//        options.value = amount
//        options.gasPrice = .automatic
//        options.gasLimit = .automatic
//        let tx1 = contract1.write("fallback",
//                                  parameters: [AnyObject](),
//                                  extraData: Data(),
//                                  transactionOptions: options)!
//        let result1 = try! tx1.send(password: "", transactionOptions: options)
//        XCTAssert(result1.hash != "")
//
//        let ethTokenAddress = EthereumAddress("0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359")!
//        let contract2 = web3.contract(Web3.Utils.erc20ABI, at: ethTokenAddress, abiVersion: 2)!
//        options.value = BigUInt(0)
//        let tx2 = contract2.write("transfer",
//                                  parameters: [ethToAddress, amount] as [AnyObject],
//                                  extraData: Data(),
//                                  transactionOptions: options)!
//        let result2 = try! tx2.send(password: "", transactionOptions: options)
//        XCTAssert(result2.hash != "")
//    }
    
}
