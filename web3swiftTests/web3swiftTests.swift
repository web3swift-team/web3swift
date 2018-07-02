//
//  web3swiftTests.swift
//  web3swiftTests
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//


import XCTest
import CryptoSwift
import BigInt
import Result
import secp256k1_ios


@testable import web3swift_iOS

class web3swiftTests: XCTestCase {
    
    func testBitFunctions () {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0,1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0,4)
        XCTAssert(first4bits == 0x0f)
    }
    
    func testCombiningPublicKeys() {
        let priv1 = Data(repeating: 0x01, count: 32)
        let pub1 = Web3.Utils.privateToPublic(priv1, compressed: true)!
        let priv2 = Data(repeating: 0x02, count: 32)
        let pub2 = Web3.Utils.privateToPublic(priv2, compressed: true)!
        let combined = SECP256K1.combineSerializedPublicKeys(keys: [pub1, pub2], outputCompressed: true)
        let compinedPriv = Data(repeating: 0x03, count: 32)
        let compinedPub = Web3.Utils.privateToPublic(compinedPriv, compressed: true)
        XCTAssert(compinedPub == combined)
    }
    
    func testChecksumAddress() {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }
    
    func testChecksumAddressParsing() {
        let input = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let addr = EthereumAddress(input);
        XCTAssert(addr != nil);
        let invalidInput = "0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let invalidAddr = EthereumAddress(invalidInput);
        XCTAssert(invalidAddr == nil);
    }


    func testPlasmaFundingTransaction() {
        let abiString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"}],\"name\":\"proveFundingWithoutDeposit\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"operators\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"depositRecords\",\"outputs\":[{\"name\":\"from\",\"type\":\"address\"},{\"name\":\"status\",\"type\":\"uint8\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"index\",\"type\":\"uint256\"},{\"name\":\"withdrawStartedTime\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"lastBlockNumber\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_user\",\"type\":\"address\"}],\"name\":\"depositRecordsForUser\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"doubleFundingRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_inputNumber1\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_inputNumber2\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"checkActualDoubleSpendProof\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"lastEthBlockNumber\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"makeTransactionIndex\",\"outputs\":[{\"name\":\"index\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"root\",\"type\":\"bytes32\"},{\"name\":\"data\",\"type\":\"bytes\"},{\"name\":\"proof\",\"type\":\"bytes\"},{\"name\":\"convertToMessageHash\",\"type\":\"bool\"}],\"name\":\"checkProof\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_inputNumber1\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_inputNumber2\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"proveDoubleSpend\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_user\",\"type\":\"address\"}],\"name\":\"withdrawRecordsForUser\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_op\",\"type\":\"address\"},{\"name\":\"_status\",\"type\":\"bool\"}],\"name\":\"setOperator\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"headers\",\"outputs\":[{\"name\":\"blockNumber\",\"type\":\"uint32\"},{\"name\":\"numTransactions\",\"type\":\"uint32\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"previousBlockHash\",\"type\":\"bytes32\"},{\"name\":\"merkleRootHash\",\"type\":\"bytes32\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"blockHeaderLength\",\"outputs\":[{\"name\":\"\",\"type\":\"uint32\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"fundingWithoutDepositRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"proveDoubleFunding\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"signer1\",\"type\":\"address\"},{\"name\":\"depositIndex1\",\"type\":\"uint256\"},{\"name\":\"transactionIndex1\",\"type\":\"uint256\"},{\"name\":\"signer2\",\"type\":\"address\"},{\"name\":\"depositIndex2\",\"type\":\"uint256\"},{\"name\":\"transactionIndex2\",\"type\":\"uint256\"}],\"name\":\"checkDoubleFundingFromInternal\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"header\",\"type\":\"bytes\"}],\"name\":\"submitBlockHeader\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"depositCounterInBlock\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_inputNumber\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"},{\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"proveSpendAndWithdraw\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"withdrawRecords\",\"outputs\":[{\"name\":\"index\",\"type\":\"uint256\"},{\"name\":\"blockNumber\",\"type\":\"uint32\"},{\"name\":\"txNumberInBlock\",\"type\":\"uint32\"},{\"name\":\"outputNumberInTX\",\"type\":\"uint8\"},{\"name\":\"beneficiary\",\"type\":\"address\"},{\"name\":\"isExpress\",\"type\":\"bool\"},{\"name\":\"status\",\"type\":\"uint8\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"timeStarted\",\"type\":\"uint256\"},{\"name\":\"timeEnded\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"doubleSpendRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"deposit\",\"outputs\":[{\"name\":\"idx\",\"type\":\"uint256\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"}],\"name\":\"makeWithdrawExpress\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"},{\"name\":\"withdrawIndex\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"spendAndWithdrawRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_success\",\"type\":\"bool\"},{\"indexed\":true,\"name\":\"_b\",\"type\":\"bytes32\"},{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"}],\"name\":\"Debug\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_2\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_3\",\"type\":\"uint256\"}],\"name\":\"DebugUint\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_r\",\"type\":\"bytes32\"},{\"indexed\":true,\"name\":\"_s\",\"type\":\"bytes32\"}],\"name\":\"SigEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_blockHash\",\"type\":\"bytes32\"}],\"name\":\"HeaderSubmittedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_amount\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawStartedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawChallengedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawCompletedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"WithdrawStartedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"WithdrawRequestAcceptedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"WithdrawFinalizedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_withdrawTxBlockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_withdrawTxNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"}],\"name\":\"ExpressWithdrawMadeEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_txIndex2\",\"type\":\"uint256\"}],\"name\":\"DoubleSpendProovedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"SpendAndWithdrawProovedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"FundingWithoutDepositEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_txIndex2\",\"type\":\"uint256\"}],\"name\":\"DoubleFundingEvent\",\"type\":\"event\"}]"
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            let address = EthereumAddress("0x158cb5485ea2e7fe03845d45c40c63469814bd9a")!
            let amount = BigUInt(10).power(18)
            let contract = Contract(abi: abiNative, at: address)
            var options = Web3Options()
            options.gasLimit = BigUInt(250000)
            options.gasPrice = BigUInt(0)
            options.value = amount
            let transaction = contract.method("deposit", options: options)
            XCTAssert(transaction != nil, "Failed plasma funding transaction")
            let requestDictionary = transaction?.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")!)
            print(requestDictionary)
            XCTAssert(requestDictionary != nil, "Failed plasma funding transaction")
        } catch {
            print(error)
            XCTFail()
        }
    }
    

    
    func testBigUIntFromHex() {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        let biguint = BigUInt(hexRepresentation, radix: 16)!
        XCTAssert(biguint == BigUInt("126978086000000000"))
    }
    

    
    
    
 
    
    func testBloom() {
        let positive = [
                "testtest",
                "test",
                "hallo",
                "other",
            ]
        let negative = [
                "tes",
                "lo",
            ]
        var bloom = EthereumBloomFilter()
        for str in positive {
            let data = str.data(using: .utf8)!
            let oldBytes = bloom.bytes
            bloom.add(BigUInt(data))
            let newBytes = bloom.bytes
            if (newBytes != oldBytes) {
                print("Added new bits")
            }
        }
        for str in positive {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data), "Failed")
        }
        for str in negative {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data) == false, "Failed")
        }
    }

    
    


    func testMakePrivateKey()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }
    
//    func testConcurrency1()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        var request = JSONRPCrequest()
//        request.method = JSONRPCmethod.getTransactionCount
//        let params = [address.address.lowercased(), "latest"] as Array<Encodable>
//        let pars = JSONRPCparams(params: params)
//        request.params = pars
//        let operation = DataFetchOperation(web3, queue: web3.queue)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, web3.queue)
//        operation.inputData = request as AnyObject
//        web3.queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency2()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let hash = "0x2c6a803416ee1118ffc3b62a3344de768c86952bcf0376bdf1e49c0fc21a062f"
//        let operation = GetTransactionReceiptOperation(web3, queue: queue)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        operation.inputData = hash as AnyObject
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency3()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = GetAccountsOperation(web3, queue: queue)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                guard let accounts = result as? [EthereumAddress] else {return XCTFail()}
//                XCTAssert(accounts.count == 1)
//                XCTAssert(accounts.first == keystoreManager.addresses?.first)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency4()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = GetBlockByNumberOperation(web3, queue: queue, blockNumber: "latest", fullTransactions: false)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency5()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = GetTransactionCountOperation(web3, queue: queue, address: address, onBlock: "latest")
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency6()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let address = EthereumAddress("0xc011bf81e3f88931cf331856e45fab6b6450e54c")!
//
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = GetBalanceOperation(web3, queue: queue, address: address, onBlock: "latest")
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                let balance = result as! BigUInt
//                let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
//                print(balString)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency7()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = GetGasPriceOperation(web3, queue: queue)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                let balance = result as! BigUInt
//                let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .Gwei, decimals: 1)
//                print(balString)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency8()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
//        var options = Web3Options.defaultOptions()
//        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
//        options.from = keystoreManager.addresses?.first
//        let intermediate = contract?.method("fallback", options: options)
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = EstimateGasOperation(web3, queue: queue, transactionIntermediate: intermediate!)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                let balance = result as! BigUInt
//                XCTAssert(balance == BigUInt(21000))
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency9()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let blockHash = "0xae6a4fb3bf690b71f2c4bc5a0ab46987fdc2c3519d1e6585b26a44b101f2166c"
//        let operation = GetBlockByHashOperation(web3, queue: queue, hash: blockHash, fullTransactions: false)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency10()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)
//        var options = Web3Options.defaultOptions()
//        options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
//        let parameters = [] as [AnyObject]
//        let intermediate = contract?.method("name", parameters:parameters,  options: options)
//        let queue = OperationQueue.init()
//        queue.maxConcurrentOperationCount = 16
//        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
//        let operation = CallOperation(web3, queue: queue, transactionIntermediate: intermediate!)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(_):
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, queue)
//        queue.addOperation(operation)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency11()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        let max = 100
//        var i = max
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)
//        var options = Web3Options.defaultOptions()
//        options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
//        for _ in 0 ... max {
//            guard let operation = ContractCallOperation.init(web3, contract: contract!, method: "name", options: options, onBlock: web3.defaultBlock) else {return XCTFail()}
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let result):
//                    print(result)
//                    fail = false
//                case .failure(_):
//                    XCTFail()
//                    fatalError()
//                }
//                i = i - 1;
//                if i == 0 {
//                    print("All done")
//                    semaphore.signal()
//                }
//            }
//            operation.next = OperationChainingType.callback(callback, web3.queue)
//            web3.queue.addOperation(operation)
//        }
//
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency12()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: nil, abiVersion: 2)
//        guard let operation = ParseBlockForEventsOperation.init(web3, queue: web3.queue, contract: contract!.contract, eventName: "Transfer", filter: nil, block: UInt64(5200120)) else {return XCTFail()}
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                XCTAssert((result as! [AnyObject]).count == 81)
//                fail = false
//            case .failure(let error):
//                print(error)
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, web3.queue)
//        web3.queue.addOperation(operation)
//
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency13()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: nil, abiVersion: 2)
//        guard let operation = ParseBlockForEventsOperation.init(web3, queue: web3.queue, contract: contract!.contract, eventName: "Transfer", filter: nil, block: "latest") else {return XCTFail()}
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(let error):
//                print(error)
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, web3.queue)
//        web3.queue.addOperation(operation)
//
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testConcurrency14()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: nil, abiVersion: 2)
//        var filter = EventFilter()
//        filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
//        filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), ([EthereumAddress("0xd5395c132c791a7f46fa8fc27f0ab6bacd824484")!] as [EventFilterable])]
//        guard let operation = ParseBlockForEventsOperation.init(web3, queue: web3.queue, contract: contract!.contract, eventName: "Transfer", filter: filter, block: UInt64(5200120)) else {return XCTFail()}
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                XCTAssert((result as! [AnyObject]).count == 1)
//                fail = false
//            case .failure(let error):
//                print(error)
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        operation.next = OperationChainingType.callback(callback, web3.queue)
//        web3.queue.addOperation(operation)
//
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
    
    func testAdvancedABIv2() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testSingle", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStaticArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")!
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testEmptyArrayDecoding() {
        let abiString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[],\"name\":\"empty\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        let contractAddress = EthereumAddress("0x200eb5ccda1c35b0f5bf82552fdd65a8aee98e79")!
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("empty", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testUserCase() {
        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        let contractAddress = EthereumAddress("0x811411e3cdfd4750cdd3552feb3b89a46ddb612e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let intermediate = contract?.method("getFlagData", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testEIP67encoding() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!)
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
//        eip67Data.data =
        let encoding = eip67Data.toString()
        print(encoding)
    }
    
    func testEIP67codeGeneration() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!)
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
        //        eip67Data.data =
        let encoding = eip67Data.toImage(scale: 5.0)
        XCTAssert(encoding != CIImage())
    }
    
    func testEIP67decoding() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!)
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
        //        eip67Data.data =
        let encoding = eip67Data.toString()
        guard let code = Web3.EIP67CodeParser.parse(encoding) else {return XCTFail()}
        XCTAssert(code.address == eip67Data.address)
        XCTAssert(code.gasLimit == eip67Data.gasLimit)
        XCTAssert(code.amount == eip67Data.amount)
    }
    
//    func testConcurrenctGetTransactionCount()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(let error):
//                print(error)
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        web3.eth.getTransactionCount(address: address, onBlock: "latest", callback: callback, queue: web3.queue) // queue should be .main here, but can not test in this case with a simple semaphore (getting a deadlock)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testGetAllTokenBalances()
//    {
//        //        let semaphore = DispatchSemaphore(value: 0)
//        let url = URL.init(string: "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json")
//        let tokensData = try! Data.init(contentsOf: url!)
//        let tokensJSON = try! JSONSerialization.jsonObject(with: tokensData, options: []) as! [[String: Any]]
//        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
//        let web3 = Web3.InfuraMainnetWeb3()
//        let userAddress = EthereumAddress("0xc011bf81e3f88931cf331856e45fab6b6450e54c")!
//        var expected = tokensJSON.count
//        print(String(expected) + " tokens to update")
//        let semaphore = DispatchSemaphore(value: 0)
//        for token in tokensJSON {
//            let tokenSymbol = token["symbol"] as! String
//            let tokenAddress = EthereumAddress(token["address"] as! String)
//            let contract = web3.contract(jsonString, at: tokenAddress, abiVersion: 2)
//            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
//            var options = Web3Options.defaultOptions()
//            options.from = userAddress
//            let parameters = [userAddress] as [AnyObject]
//            let transactionIntermediate = contract?.method("balanceOf", parameters:parameters, options: options)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let balanceResult):
//                    guard let result = balanceResult as? [String: Any] else {
//                        XCTFail()
//                        break
//                    }
//                    guard let bal = result["balance"] as? BigUInt else {
//                        XCTFail()
//                        break
//                    }
//                    print("Balance of " + tokenSymbol + " is " + String(bal))
//                case .failure(let error):
//                    print(error)
//                    XCTFail()
////                    fatalError()
//                }
//                OperationQueue.current?.underlyingQueue?.async {
//                    expected = expected - 1
////                    print(String(expected) + " tokens left to update")
//                    if expected == 0 {
//                        semaphore.signal()
//                    }
//                }
//
//            }
//            transactionIntermediate?.call(options: options, onBlock: "latest", callback: callback, queue: web3.queue)
//        }
//        let _ = semaphore.wait(timeout: .distantFuture)
//    }
//
//    func testGetAllTokenNames()
//    {
//        //        let semaphore = DispatchSemaphore(value: 0)
//        let url = URL.init(string: "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json")
//        let tokensData = try! Data.init(contentsOf: url!)
//        let tokensJSON = try! JSONSerialization.jsonObject(with: tokensData, options: []) as! [[String: Any]]
//        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
//        let web3 = Web3.InfuraMainnetWeb3()
//        let userAddress = EthereumAddress("0xc011bf81e3f88931cf331856e45fab6b6450e54c")!
//        var expected = tokensJSON.count
//        print(String(expected) + " tokens to update")
//        let semaphore = DispatchSemaphore(value: 0)
//        for token in tokensJSON {
//            let tokenSymbol = token["symbol"] as! String
//            let tokenAddress = EthereumAddress(token["address"] as! String)
//            let contract = web3.contract(jsonString, at: tokenAddress, abiVersion: 2)
//            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
//            var options = Web3Options.defaultOptions()
//            options.from = userAddress
//            let transactionIntermediate = contract?.method("name", options: options)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let balanceResult):
//                    guard let result = balanceResult as? [String: Any] else {
//                        XCTFail()
//                        break
//                    }
//                    guard let bal = result["0"] as? String else {
//                        XCTFail()
//                        break
//                    }
//                    print("Name of " + tokenSymbol + " is " + String(bal))
//                case .failure(let error):
//                    print(error)
//                    print("Name of " + tokenSymbol + " is undefined")
////                    XCTFail()
////                    fatalError()
//                }
//                OperationQueue.current?.underlyingQueue?.async {
//                    expected = expected - 1
//                    if expected == 0 {
//                        semaphore.signal()
//                    }
//                }
//
//            }
//            transactionIntermediate?.call(options: options, onBlock: "latest", callback: callback, queue: web3.queue)
//        }
//        let _ = semaphore.wait(timeout: .distantFuture)
//    }
//
//    func testEthSendOperationsExample() {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraRinkebyWeb3()
//        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
//        var options = Web3Options.defaultOptions()
//        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
//        options.from = keystoreManager.addresses?.first
//        let intermediate = contract?.method("fallback", options: options)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(let error):
//                print(error)
//                if case .nodeError(_) = error {
//                    fail = false
//                    break
//                }
//                XCTFail()
////                fatalError()
//            }
//            semaphore.signal()
//        }
//        intermediate?.send(password: "", options: options, callback: callback, queue: web3.queue)
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssertTrue(!fail)
//    }
    
    func testNonDeterministicSignature() {
        var unsuccesfulNondeterministic = 0;
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            let randomHash = Data.randomBytes(length: 32)!
            let randomPrivateKey = Data.randomBytes(length: 32)!
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            allAttempts = allAttempts + 1
            let signature = SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true)
            guard let serialized = signature.serializedSignature else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard let recovered = SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true) else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard let original = SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true) else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard recovered == original else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
        }
        print("Problems with \(unsuccesfulNondeterministic) non-deterministic signatures out from \(allAttempts)")
        XCTAssert(unsuccesfulNondeterministic == 0)
    }
    
    func testDeterministicSignature() {
        var unsuccesfulDeterministic = 0;
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            let randomHash = Data.randomBytes(length: 32)!
            let randomPrivateKey = Data.randomBytes(length: 32)!
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            allAttempts = allAttempts + 1
            let signature = SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: false)
            guard let serialized = signature.serializedSignature else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard let recovered = SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true) else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard let original = SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true) else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard recovered == original else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            
        }
        print("Problems with \(unsuccesfulDeterministic) deterministic signatures out from \(allAttempts)")
        XCTAssert(unsuccesfulDeterministic == 0)
    }
    
    func testPrivateToPublic() {
        let randomPrivateKey = Data.randomBytes(length: 32)!
        guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {return XCTFail()}
        guard var previousPublic = SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey) else {return XCTFail()}
        for _ in 0 ..< 100000 {
            guard let pub = SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey) else {return XCTFail()}
            guard Data(toByteArray(previousPublic.data)) == Data(toByteArray(pub.data)) else {
                return XCTFail()
            }
            previousPublic = pub
        }
    }
    
    func testSerializationAndParsing() {
        for _ in 0 ..< 1024 {
            let randomHash = Data.randomBytes(length: 32)!
            let randomPrivateKey = Data.randomBytes(length: 32)!
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            guard var signature = SECP256K1.recoverableSign(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true) else {return XCTFail()}
            guard let serialized = SECP256K1.serializeSignature(recoverableSignature: &signature) else {return XCTFail()}
            guard let parsed = SECP256K1.parseSignature(signature: serialized) else {return XCTFail()}
            let sigData = Data(toByteArray(signature.data))
            let parsedData = Data(toByteArray(parsed.data))
            guard sigData == parsedData else {
                for i in 0 ..< sigData.count {
                    if sigData[i] != parsedData[i] {
                        print(i)
                    }
                }
                return XCTFail()
            }
        }
    }
    
    func testPersonalSignature() {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signRes = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        guard case .success(let signature) = signRes else {return XCTFail()}
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let recoveredSigner = web3.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)
        guard case .success(let signer) = recoveredSigner else {return XCTFail()}
        XCTAssert(expectedAddress == signer, "Failed to sign personal message")
    }
    
    func testPersonalSignatureOnContract() {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signRes = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        guard case .success(let signature) = signRes else {return XCTFail()}
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let jsonString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"}],\"name\":\"hashPersonalMessage\",\"outputs\":[{\"name\":\"hash\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"recoverSigner\",\"outputs\":[{\"name\":\"signer\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"}]"
        let contract = web3.contract(jsonString, at: EthereumAddress("0x6f1745a39059268e8e4572e97897b50e4aab62a8"), abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = expectedAddress
        var intermediate = contract?.method("hashPersonalMessage", parameters: [message as AnyObject], options: options)
        var result = intermediate!.call(options: nil)
        switch result {
        case .success(let res):
            guard let hash = res["hash"]! as? Data else {return XCTFail()}
            XCTAssert(Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)! == hash)
        case .failure(let error):
            print(error)
            XCTFail()
        }
        
        intermediate = contract?.method("recoverSigner", parameters: [message, unmarshalledSignature.v, Data(unmarshalledSignature.r), Data(unmarshalledSignature.s)] as [AnyObject], options: options)
        result = intermediate!.call(options: nil)
        switch result {
        case .success(let res):
            guard let signer = res["signer"]! as? EthereumAddress else {return XCTFail()}
            print(signer)
            XCTAssert(signer == expectedAddress)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testUserCaseEventParsing() {
        let contractAddress = EthereumAddress("0x7ff546aaccd379d2d1f241e1d29cdd61d4d50778")
        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {return XCTFail()}
        let present = eventParser.parseBlockByNumber(UInt64(2138657))
        guard case .success(let pres) = present else {return XCTFail()}
        print(pres)
        XCTAssert(pres.count == 1)
    }
    
    func testTokenBalanceTransferOnMainNet() {
        // BKX TOKEN
        let web3 = Web3.InfuraMainnetWeb3()
        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
        var options = Web3Options()
        options.from = coldWalletAddress
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
        let bkxBalanceSend = contract.method("transfer", parameters: [coldWalletAddress, BigUInt(1)] as [AnyObject], options: options)!.call(options: nil)
        switch bkxBalanceSend {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testTokenBalanceTransferOnMainNetUsingConvenience() {
        // BKX TOKEN
        let web3 = Web3.InfuraMainnetWeb3()
        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress:contractAddress, from: coldWalletAddress, to: coldWalletAddress, amount: "1.0")
        let gasEstimate = intermediate!.estimateGas(options: nil)
        switch gasEstimate {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
        var options = Web3Options();
        options.gasLimit = gasEstimate.value!
        let bkxBalanceSend = intermediate!.call(options: options)
        switch bkxBalanceSend {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testDecodeInputData() {
        let contract = ContractV2.init(Web3.Utils.erc20ABI)!
        let dataToDecode = Data.fromHex("0xa9059cbb000000000000000000000000cdd45864e794fe5e3e1b0045b77e62f4c43b8bd9000000000000000000000000000000000000000000000224b5f018c3e30142d5")!
        let decoded = contract.decodeInputData("transfer", data: dataToDecode)
        XCTAssert(decoded!["_to"] as? EthereumAddress == EthereumAddress("0xcdd45864e794fe5e3e1b0045b77e62f4c43b8bd9")!)
    }
    
    func testDecodeInputDataWithoutMethodName() {
        let contract = ContractV2.init(Web3.Utils.erc20ABI)!
        let dataToDecode = Data.fromHex("0xa9059cbb000000000000000000000000cdd45864e794fe5e3e1b0045b77e62f4c43b8bd9000000000000000000000000000000000000000000000224b5f018c3e30142d5")!
        let decoded = contract.decodeInputData(dataToDecode)
        XCTAssert(decoded!["_to"] as? EthereumAddress == EthereumAddress("0xcdd45864e794fe5e3e1b0045b77e62f4c43b8bd9")!)
    }
    
    func testNumberFormattingUtil() {
        let balance = BigInt("-1000000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1")
    }
    
    func testNumberFormattingUtil2() {
        let balance = BigInt("-1000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0010")
    }
    
    func testNumberFormattingUtil3() {
        let balance = BigInt("-1000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0000")
    }
    
    func testNumberFormattingUtil4() {
        let balance = BigInt("-1000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "-0,000001000")
    }
    
    func testNumberFormattingUtil5() {
        let balance = BigInt("-1")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssert(formatted == "-1e-18")
    }
    
    func testNumberFormattingUtil6() {
        let balance = BigInt("0")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "0")
    }
    
    func testNumberFormattingUtil7() {
        let balance = BigInt("-1100000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1,1000")
    }
    
    func testIBANcreation() {
        let iban = "XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS"
        let native = Web3.Utils.Iban(iban)
        XCTAssert(native != nil)
        let expectedAddress = "0x00c5496aEe77C1bA1f0854206A26DdA82a81D6D8"
        let createdAddress = native?.toEthereumAddress()?.address
        XCTAssert(createdAddress == expectedAddress)
        
        let address = EthereumAddress("0x03c5496aee77c1ba1f0854206a26dda82a81d6d8")!
        let fromAddress = Web3.Utils.Iban(address)
        let ibn = fromAddress?.iban
        XCTAssert(ibn == "XE83FUTTUNPK7WZJSGGCWVEBARQWQ8YML4")
    }
    
    func testSendETH() {
        guard let keystoreData = getKeystoreData() else {return}
        guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let keystoreManager = KeystoreManager.init([keystoreV3])
        web3Rinkeby.addKeystoreManager(keystoreManager)
        guard case .success(let gasPriceRinkeby) = web3Rinkeby.eth.getGasPrice() else {return}
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        guard let intermediate = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
        var options = Web3Options.defaultOptions()
        options.from = keystoreV3.addresses?.first
        options.gasPrice = gasPriceRinkeby
        let result = intermediate.send(password: "BANKEXFOUNDATION", options: options)
        switch result {
        case .success(let res):
            print(res)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testERC20tokenBalance() {
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!, abiVersion: 2)
        var options = Web3Options();
        options.from = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let addressOfUser = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        guard let tokenBalanceResult = contract?.method("balanceOf", parameters: [addressOfUser] as [AnyObject], options: options)?.call(options: nil) else {return XCTFail()}
        guard case .success(let tokenBalance) = tokenBalanceResult, let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
        print(String(bal))
    }
    
    func testGenericRPCresponse() {
        let hex = "0x1"
        let rpcResponse = JSONRPCresponse(id: 1, jsonrpc: "2.0", result: hex, error: nil)
        let value: BigUInt? = rpcResponse.getValue()
        XCTAssert(value == 1)
    }
    
    func testPublicMappingsAccess() {
        do {
            let jsonString = "[{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"users\",\"outputs\":[{\"name\":\"name\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"userDeviceCount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
            let web3 = Web3.InfuraRinkebyWeb3()
            guard let addr = EthereumAddress("0xdef61132a0c1259464b19e4590e33666aae38574") else {return XCTFail()}
            let contract = web3.contract(jsonString, at: addr, abiVersion: 2)
            XCTAssert(contract != nil)
            let allMethods = contract!.contract.allMethods
            let userDeviceCount = try contract!.method("userDeviceCount", parameters: [addr as AnyObject], options: nil)?.callPromise().wait()
            print(userDeviceCount)
            let totalUsers = try contract!.method("totalUsers", parameters: [], options: nil)?.callPromise().wait()
            print(totalUsers)
            let user = try contract!.method("users", parameters: [0 as AnyObject], options: nil)?.callPromise().wait()
            print(user)
            print(allMethods)
        } catch {
            print(error)
        }
    }
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

